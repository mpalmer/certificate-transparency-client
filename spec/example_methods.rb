module ExampleMethods
	def fixture_file(f)
		File.expand_path("../fixtures/#{f}", __FILE__)
	end

	def read_fixture_file(f)
		File.read(fixture_file(f))
	end
end
