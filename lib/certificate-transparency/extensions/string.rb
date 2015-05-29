# Extensions to the String class.
#
class String
	# Return a new string, which is simply the object base64 encoded.
	#
	def base64
		[self.to_s].pack("m0")
	end

	# Return a new string, which is simply the object base64 decoded.
	#
	def unbase64
		self.to_s.unpack("m").first
	end
end
