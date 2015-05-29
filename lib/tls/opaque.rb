# An implementation of the TLS 1.2 (RFC5246) "variable length" opaque type.
#
# You can create an instance of this type by passing in a stringish to be
# encoded, and a "maximum length", like this:
#
#    TLS::Opaque.new("Hello World", 2**16-1)
#
# If you have a TLS::Opaque-encoded blob, and you'd like to get the
# content out of it, you can use `.from_blob` to create a TLS::Opaque object
# that will contain the data you seek:
#
#    TLS::Opaque.from_blob("\x00\x0BHello World", 2**16-1)
#
# In both cases, you need to specify what the maximum length of the `value`
# can be, because that is what determines how many bytes the length field
# takes up at the beginning of the string.
#
# To get the "encoded" form,, call `#to_blob`:
#
#    TLS::Opaque.new("Hello World", 255).to_blob
#    => "\x0BHello World"
#
# Or, to get the string itself out, call `#value`:
#
#    TLS::Opaque.from_blob("\x0BHello World", 255)[0].value
#    => "Hello World"
#
# Passing in a value or blob which is longer than the maximum length
# specified will result in `ArgumentError` being thrown.
#
class TLS::Opaque
	attr_reader :value

	# Parse out an opaque string from a blob, as well as returning
	# any remaining data.  The `maxlen` parameter is required to
	# know how many octets at the beginning of the string to read to
	# determine the length of the opaque string.
	#
	# Returns a two-element array, `[TLS::Opaque, String]`, being a
	# `TLS::Opaque` instance retrieved from the blob provided, and a `String`
	# containing any remainder of the blob that wasn't considered part of the
	# `TLS::Opaque`.  This second element will *always* be a string, but it
	# may be an empty string, if the `TLS::Opaque` instance was the entire
	# blob.
	#
	# This method will raise `ArgumentError` if the length encoded at the
	# beginning of `blob` is longer than the data in `blob`, or if it is
	# larger than `maxlen`.
	#
	def self.from_blob(blob, maxlen)
		len_bytes = lenlen(maxlen)

		len = blob[0..len_bytes-1].split('').inject(0) do |total, c|
			total * 256 + c.ord
		end

		if len > maxlen
			raise ArgumentError,
			      "Encoded length (#{len}) is greater than maxlen (#{maxlen})"
		end

		if len > blob[len_bytes..-1].length
			raise ArgumentError,
			      "Encoded length (#{len}) is greater than the number of bytes available"
		end

		[TLS::Opaque.new(blob[len_bytes..(len_bytes+len-1)], maxlen),
		 blob[(len_bytes+len)..-1]
		]
	end

	def initialize(str, maxlen)
		unless maxlen.is_a? Integer
			raise ArgumentError,
			      "maxlen must be an Integer"
		end

		if str.length > maxlen
			raise ArgumentError,
			      "value given is longer than maxlen (#{maxlen})"
		end

		@maxlen = maxlen
		@value  = str
	end

	def to_blob
		len = value.length
		params = []
		self.class.lenlen(@maxlen).times do
			params.unshift(len % 256)
			len /= 256
		end

		params << value

		params.pack("C#{self.class.lenlen(@maxlen)}a*")
	end

	private
	def self.lenlen(len)
		(Math.log2(len).ceil / 8.0).ceil
	end
end
