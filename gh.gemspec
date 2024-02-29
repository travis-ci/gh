# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'gh/version'

Gem::Specification.new do |s|
  s.platform              = Gem::Platform::RUBY
  s.name                  = 'gh'
  s.version               = GH::VERSION
  s.summary               = 'layered github client'
  s.description           = 'multi-layer client for the github api v3'

  s.authors               = ['Travis CI']
  s.email                 = 'contact@travis-ci.org'
  s.homepage              = 'https://github.com/travis-ci/gh'

  s.license               = 'MIT'

  s.files                 = Dir['lib/**/*', 'LICENSE']
  s.require_path          = 'lib'

  s.required_ruby_version = '>= 3.2', '< 4'

s.add_runtime_dependency 'activesupport', '7.0.6' # this is fixed here do to travis-api dependency in predicate_builder.rb monkey patch that is for version 7.0.6
  s.add_runtime_dependency 'addressable', '~> 2.8'
  s.add_runtime_dependency 'faraday', '~> 2'
  s.add_runtime_dependency 'faraday-retry'
  s.add_runtime_dependency 'faraday-typhoeus'
  s.add_runtime_dependency 'multi_json', '~> 1'
  s.add_runtime_dependency 'net-http-persistent', '~> 4'
  s.add_runtime_dependency 'net-http-pipeline'
end
