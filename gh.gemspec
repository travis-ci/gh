# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gh/version"

Gem::Specification.new do |s|
  s.name        = "gh"
  s.version     = GH::VERSION
  s.authors     = ["Konstantin Haase"]
  s.email       = ["konstantin.mailinglists@googlemail.com"]
  s.homepage    = "http://gh.rkh.im/"
  s.summary     = %q{layered github client}
  s.description = %q{multi-layer client for the github api v3}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'

  s.add_runtime_dependency 'faraday',     '~> 0.7'
  s.add_runtime_dependency 'backports',   '~> 2.3'
  s.add_runtime_dependency 'multi_json',  '~> 1.0'
end
