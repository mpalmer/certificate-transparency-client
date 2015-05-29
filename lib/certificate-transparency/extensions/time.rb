class Time
	def ms
		(self.to_f * 1000).to_i
	end

	def self.ms(i)
		Time.at(i.to_f / 1000)
	end
end
