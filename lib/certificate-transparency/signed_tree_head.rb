require 'json'
require 'tls'

class CertificateTransparency::SignedTreeHead
	attr_accessor :tree_size
	attr_accessor :timestamp
	attr_accessor :root_hash
	attr_accessor :signature

	def self.from_json(json)
		doc = JSON.parse(json)

		self.new.tap do |sth|
			sth.tree_size = doc['tree_size']
			sth.timestamp = Time.at(doc['timestamp'].to_f / 1000)
			sth.root_hash = doc['sha256_root_hash'].unpack("m").first
			sth.signature = doc['tree_head_signature'].unpack("m").first
		end
	end

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
