# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'tinder/version'

Gem::Specification.new do |gem|
  gem.add_dependency 'eventmachine', '~> 1.0'
  gem.add_dependency 'faraday', '>= 0.8'
  gem.add_dependency 'faraday_middleware', '~> 0.9'
  gem.add_dependency 'hashie', ['>= 1.0', '< 3']
  gem.add_dependency 'json', '~> 1.8.0'
  gem.add_dependency 'mime-types', '~> 1.19'
  gem.add_dependency 'multi_json', '~> 1.7'
  gem.add_dependency 'twitter-stream', '~> 0.1'

  gem.add_development_dependency 'fakeweb'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.authors = ["Brandon Keepers", "Brian Ryckbost", "Tony Coconate"]
  gem.description = %q{A Ruby API for interfacing with Campfire, the 37Signals chat application.}
  gem.email = ['brandon@opensoul.org', 'bryckbost@gmail.com', 'me@tonycoconate.com']
  gem.extra_rdoc_files = ['README.markdown']
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/collectiveidea/tinder'
  gem.name = 'tinder'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  gem.summary = %q{Ruby wrapper for the Campfire API}
  gem.test_files = `git ls-files -- spec/*`.split("\n")
  gem.version = Tinder::VERSION
end
