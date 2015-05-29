require 'json'
require 'tls'

# A CT SignedTreeHead (RFC6962 s3.5, s4.3).
#
class CertificateTransparency::SignedTreeHead
	attr_accessor :tree_size
	attr_accessor :timestamp
	attr_accessor :root_hash
	attr_accessor :signature

	# Create a new SignedTreeHead instance from the JSON returned
	# by `/ct/v1/get-sth`.
	#
	def self.from_json(json)
		doc = JSON.parse(json)

		self.new.tap do |sth|
			sth.tree_size = doc['tree_size']
			sth.timestamp = Time.at(doc['timestamp'].to_f / 1000)
			sth.root_hash = doc['sha256_root_hash'].unpack("m").first
			sth.signature = doc['tree_head_signature'].unpack("m").first
		end
	end

	# Determine whether or not the signature that was provided in the
	# signed tree head is a valid one, based on the provided key.
	#
	# @param pk [String] the raw binary form of the public key of the
	#   log.
	#
	# @return Boolean
	#
	def valid?(pk)
		key = OpenSSL::PKey::EC.new(pk)

		blob = [
			CT::Version[:v1],
			CT::SignatureType[:tree_hash],
		   timestamp.ms,
		   tree_size,
		   root_hash
		].pack("ccQ>Q>a32")

		ds = TLS::DigitallySigned.from_blob(signature)
		ds.content = blob
		ds.key = key

		ds.valid?
	end
end
