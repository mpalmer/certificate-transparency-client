require 'spork'

Spork.prefork do
	require 'bundler'
	Bundler.setup(:default, :development)
	require 'rspec/core'
	require 'rspec/mocks'

	RSpec.configure do |config|
		config.fail_fast = true
#		config.full_backtrace = true

		config.expect_with :rspec do |c|
			c.syntax = :expect
		end
	end
end

Spork.each_run do
	require 'certificate-transparency-client'

	require_relative 'example_methods'
	require_relative 'example_group_methods'

	RSpec.configure do |config|
		config.include ExampleMethods
		config.extend  ExampleGroupMethods
	end
end
