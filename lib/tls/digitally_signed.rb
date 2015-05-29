require 'openssl'

unless OpenSSL::PKey::EC.instance_methods.include?(:private?)
	OpenSSL::PKey::EC.class_eval("alias_method :private?, :private_key?")
end

# Create a `DigitallySigned` struct, as defined by RFC5246 s4.7, and adapted
# for the CertificateTransparency system (that is, ECDSA using the NIST
# P-256 curve is the only signature algorithm supported, and SHA-256 is the
# only hash algorithm supported).
#
class TLS::DigitallySigned
	# Create a new `DigitallySigned` struct.
	#
	# Takes a number of named options:
	#
	# * `:key` -- (required) An instance of `OpenSSL::PKey::EC`.  If you pass
	#   in `:blob` as well, then this can be either a public key or a private
	#   key (because you only need a public key for validating a signature),
	#   but if you only pass in `:content`, you must provide a private key
	#   here.
	#
	#   This key *must* be generated with the NIST P-256 curve (known to
	#   OpenSSL as `prime256v1`) in order to be compliant with the CT spec.
	#   However, we can't validate that, so it's up to you to make sure you
	#   do it right.
	#
	# * `:content` -- (required) The content to sign, or verify the signature
	#   of.  This can be any string.
	#
	# * `:blob` -- An existing encoded `DigitallySigned` struct you'd like to
	#   have decoded and verified against `:content` with `:key`.
	#
	# Raises an `ArgumentError` if you try to pass in anything that doesn't
	# meet the rather stringent requirements.
	#
	def self.from_blob(blob)
		hash_algorithm, signature_algorithm, len, signature = blob.unpack("CCna*")

		if signature_algorithm != ::TLS::SignatureAlgorithm[:ecdsa]
			raise ArgumentError,
			      "Signature specified in blob is not ECDSA"
		end

		if hash_algorithm != ::TLS::HashAlgorithm[:sha256]
			raise ArgumentError,
			      "Hash algorithm specified in blob is not SHA256"
		end

		if len != signature.length
			raise ArgumentError,
			      "Unexpected signature length " +
			      "(expected #{len}, actually got #{signature.length}"
		end

		TLS::DigitallySigned.new.tap do |ds|
			ds.hash_algorithm = hash_algorithm
			ds.signature_algorithm = signature_algorithm
			ds.signature = signature
		end
	end

	attr_accessor :content, :hash_algorithm, :signature_algorithm, :signature
	attr_reader :key

	def key=(k)
		unless k.is_a? OpenSSL::PKey::EC
			raise ArgumentError,
			      "Key must be an instance of OpenSSL::PKey::EC"
		end

		@key = k
	end

	# Return a binary string which represents a `DigitallySigned` struct of
	# the content passed in.
	#
	def to_blob
		if @key.nil?
			raise RuntimeError,
			      "No key has been supplied"
		end
		begin
			@signature ||= @key.sign(OpenSSL::Digest::SHA256.new, @content)
		rescue ArgumentError
			raise RuntimeError,
			      "Must have a private key in order to make a signature"
		end

		[
			@hash_algorithm,
			@signature_algorithm,
			@signature.length,
			@signature
		].pack("CCna*").force_encoding("BINARY")
	end

	# Verify whether or not the `signature` struct given is a valid signature
	# for the key/content/blob combination provided to the constructor.
	#
	def valid?
		if @key.nil?
			raise RuntimeError,
			      "No key has been specified"
		end

		if @signature.nil?
			raise RuntimeError,
			      "No signature is available yet"
		end

		if @content.nil?
			raise RuntimeError,
			      "No content has been specified yet"
		end

		@key.verify(OpenSSL::Digest::SHA256.new, @signature, @content)
	end
end
