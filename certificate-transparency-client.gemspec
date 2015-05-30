begin
	require 'git-version-bump'
rescue LoadError
	nil
end

Gem::Specification.new do |s|
	s.name = "certificate-transparency-client"

	s.version = GVB.version rescue "0.0.0.1.NOGVB"
	s.date    = GVB.date    rescue Time.now.strftime("%Y-%m-%d")

	s.platform = Gem::Platform::RUBY

	s.summary  = "A client for RFC6962 Certificate Transparency log servers"

	s.authors  = ["Matt Palmer"]
	s.email    = ["theshed+certificate-transparency-client@hezmatt.org"]
	s.homepage = "http://theshed.hezmatt.org/certificate-transparency-client"

	s.files = `git ls-files -z`.split("\0").reject { |f| f =~ /^(G|spec|Rakefile)/ }

	s.required_ruby_version = ">= 1.9.3"

	s.add_runtime_dependency 'certificate-transparency', '~> 0.0'

	s.add_development_dependency 'bundler'
	s.add_development_dependency 'github-release'
	s.add_development_dependency 'guard-spork'
	s.add_development_dependency 'guard-rspec'
	s.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
	# Needed for guard
	s.add_development_dependency 'rb-inotify', '~> 0.9'
	s.add_development_dependency 'redcarpet'
	s.add_development_dependency 'rspec'
	s.add_development_dependency 'yard'
end
