source "http://rubygems.org"

# Specify your gem's dependencies in gh.gemspec
gemspec
gem 'rake'
platform(:jruby) { gem 'jruby-openssl' }

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
