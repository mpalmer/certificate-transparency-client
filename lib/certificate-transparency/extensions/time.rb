# Extensions to the Time class.
#
class Time
	# Return the time represented by this object, in milliseconds since the
	# epoch.
	#
	def ms
		(self.to_f * 1000).to_i
	end

	# Create a new instance of Time, set to the given number of milliseconds
	# since the epoch.
	#
	def self.ms(i)
		Time.at(i.to_f / 1000)
	end
end
