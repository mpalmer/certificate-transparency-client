require 'openssl'

class CertificateTransparency::Client
	def initialize(url, opts = {})
		unless opts.is_a? Hash
			raise ArgumentError,
			      "Must pass a hash of options as second argument"
		end

		if opts[:public_key]
			begin
				@pubkey = if opts[:public_key].valid_encoding? && opts[:public_key] =~ /^[A-Za-z0-9+\/]+=*$/
					OpenSSL::PKey::EC.new(opts[:public_key].unpack("m").first)
				else
					OpenSSL::PKey::EC.new(opts[:public_key])
				end
			rescue OpenSSL::PKey::ECError
				raise ArgumentError,
				      "Invalid public key"
			end
		end

		@url = URI(url)
	end
end

unless Kernel.const_defined?(:CT)
	CT = CertificateTransparency
end
