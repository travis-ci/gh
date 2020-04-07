# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "gh/version"

Gem::Specification.new do |s|
  s.name        = "gh"
  s.version     = GH::VERSION
  s.authors     = ["Konstantin Haase"]
  s.email       = ["konstantin.mailinglists@googlemail.com"]
  s.homepage    = "https://github.com/travis-ci/gh"
  s.summary     = %q{layered github client}
  s.description = %q{multi-layer client for the github api v3}
  s.license     = "MIT"

  s.required_ruby_version = '>= 2.3.0'

  s.files         = `git ls-files -- lib LICENSE`.split("\n")

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'

  s.add_runtime_dependency 'faraday',     '~> 0.9'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.14'
  s.add_runtime_dependency 'backports'
  s.add_runtime_dependency 'activesupport', '~> 5.0'
  s.add_runtime_dependency 'multi_json',  '~> 1.0'
  s.add_runtime_dependency 'addressable', '~> 2.4'
  s.add_runtime_dependency 'net-http-persistent', '~> 3.0'
end
