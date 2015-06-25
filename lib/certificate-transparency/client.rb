require 'certificate-transparency'
require 'openssl'
require 'uri'

# Interact with a Certificate Transparency server.
#
class CertificateTransparency::Client
	# Base class for all errors from CT::Client.
	#
	class Error < StandardError; end

	# Indicates an error in making a HTTP request.
	#
	class HTTPError < Error; end

	# Indicates an error in parsing a response from the server.
	#
	class DataError < Error; end

	# The public key of the log, as specified in the constructor.
	#
	# @return [OpenSSL::PKey::PKey]
	#
	attr_reader :public_key

	# Create thyself a new CT::Client.
	#
	# @param url [String] the "base" URL to the CT log, without any
	#   `/ct/v1` bits in it.
	#
	# @param opts [Hash] any options you'd like to pass.
	#
	# @option public_key [String] either the "raw" bytes of a log's public
	#   key, or the base64-encoded form of same.
	#
	# @return [CT::Client]
	#
	def initialize(url, opts = {})
		unless opts.is_a? Hash
			raise ArgumentError,
			      "Must pass a hash of options as second argument"
		end

		if opts[:public_key]
			pkdata = if opts[:public_key].valid_encoding? && opts[:public_key] =~ /^[A-Za-z0-9+\/]+=*$/
				opts[:public_key].unpack("m").first
			else
				opts[:public_key]
			end

			@public_key = begin
				OpenSSL::PKey::EC.new(pkdata)
			rescue ArgumentError
				begin
					OpenSSL::PKey::RSA.new(pkdata)
				rescue StandardError => ex
					raise "Invalid public key: #{ex.message} (#{ex.class})"
				end
			rescue StandardError => ex
				raise ArgumentError,
				      "Invalid public key: #{ex.message} (#{ex.class})"
			end
		end

		@url = URI(url)
	end

	# Retrieve the current Signed Tree Head from the log.
	#
	# @return [CT::SignedTreeHead]
	#
	# @raise [CT::Client::HTTPError] if something goes wrong with the HTTP
	#   request.
	#
	def get_sth
		CT::SignedTreeHead.from_json(make_request("get-sth"))
	end

	# Retrieve one or more entries from the log.
	#
	# @param first [Integer] the 0-based index of the first entry in the log
	#   that you wish to retrieve.
	#
	# @param last [Integer] the 0-base indexd of the last entry in the log
	#   that you wish to retrieve.  Note that you may not get as many entries
	#   as you requested, due to limits in the response size that are imposed
	#   by many log servers.
	#
	#   If `last` is not specified, this method will attempt to retrieve as
	#   many entries as the log is willing and able to hand over.
	#
	# @return [Array<CT::LogEntry>]
	#
	# @raise [CT::Client::HTTPError] if something goes wrong with the HTTP
	#   request.
	#
	def get_entries(first, last = nil)
		last ||= get_sth.tree_size - 1

		entries_json = make_request("get-entries", :start => first, :end => last)
		JSON.parse(entries_json)["entries"].map do |entry|
			CT::LogEntry.from_json(entry.to_json)
		end
	end

	# Retrieve the full set of roots publicised as being supported by this log.
	#
	# @return [Array<OpenSSL::X509::Certificate>]
	#
	# @raise [CT::Client::HTTPError] if something went wrong with the HTTP request.
	#
	# @raise [CT::Client::DataError] if the data returned didn't meet our expectations.
	#
	def get_roots
		json = make_request("get-roots")

		begin
			JSON.parse(json)["certificates"].map do |c|
				OpenSSL::X509::Certificate.new(c.unpack("m").first)
			end
		rescue StandardError => ex
			raise CT::Client::DataError,
			      "Failed to parse get-roots response: #{ex.message} (#{ex.class})"
		end
	end

	private

	# Make a request to the log server.
	#
	# @param op [String] the bit after `/ct/v1/` in the URL path.
	#
	# @param params [Hash<#to_s, #to_s>] any query params you wish to send
	#   off with the request.
	#
	# @return [String]
	#
	# @raise [CT:Client::HTTPError] if anything goes spectacularly wrong.
	#
	def make_request(op, params = nil)
		resp = proxy.get_response(url(op, params))

		if resp.code != "200"
			raise CT::Client::HTTPError,
			      "Failed to #{op}: got HTTP #{resp.code}"
		end

		if resp["Content-Type"] !~ /^application\/json($|;)/
			raise CT::Client::HTTPError,
			      "Failed to #{op}: received incorrect Content-Type (#{resp["Content-Type"]})"
		end

		resp.body
	end

	# Generate a URL for the given `op` and `params`.
	#
	# @see {#make_request}.
	#
	def url(op, params = nil)
		@url.dup.tap do |url|
			url.path += "/ct/v1/#{op}"
			if params
				url.query = params.map { |k,v| "#{k}=#{v}" }.join("&")
			end
		end
	end

	def proxy
		@proxy ||= begin
			url = URI(ENV["http_proxy"].to_s)

			Net::HTTP.Proxy(url.hostname, url.port)
		end
	end
end
