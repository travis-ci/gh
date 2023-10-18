# -*- encoding: utf-8 -*-
# stub: gh 0.18.0 ruby lib

Gem::Specification.new do |s|
  s.name = "gh".freeze
  s.version = "0.18.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Konstantin Haase".freeze]
  s.date = "2023-07-26"
  s.description = "multi-layer client for the github api v3".freeze
  s.email = ["konstantin.mailinglists@googlemail.com".freeze]
  s.files = ["LICENSE".freeze, "lib/gh.rb".freeze, "lib/gh/cache.rb".freeze, "lib/gh/case.rb".freeze, "lib/gh/custom_limit.rb".freeze, "lib/gh/error.rb".freeze, "lib/gh/instrumentation.rb".freeze, "lib/gh/lazy_loader.rb".freeze, "lib/gh/link_follower.rb".freeze, "lib/gh/merge_commit.rb".freeze, "lib/gh/nested_resources.rb".freeze, "lib/gh/normalizer.rb".freeze, "lib/gh/pagination.rb".freeze, "lib/gh/parallel.rb".freeze, "lib/gh/remote.rb".freeze, "lib/gh/response.rb".freeze, "lib/gh/response_wrapper.rb".freeze, "lib/gh/response_x_header_formatter.rb".freeze, "lib/gh/stack.rb".freeze, "lib/gh/token_check.rb".freeze, "lib/gh/version.rb".freeze, "lib/gh/wrapper.rb".freeze]
  s.homepage = "https://github.com/travis-ci/gh".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.4.17".freeze
  s.summary = "layered github client".freeze

  s.installed_by_version = "3.4.17" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<faraday>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<faraday_middleware>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5", "< 6.1"])
  s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.4"])
  s.add_runtime_dependency(%q<net-http-persistent>.freeze, ["~> 2.9"])
  s.add_runtime_dependency(%q<net-http-pipeline>.freeze, [">= 0"])
end
