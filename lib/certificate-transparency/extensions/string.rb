class String
	def base64
		[self.to_s].pack("m0")
	end

	def unbase64
		self.to_s.unpack("m").first
	end
end
