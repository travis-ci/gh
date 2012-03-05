require 'gh/version'
require 'backports'
require 'forwardable'

module GH
  autoload :Cache,      'gh/cache'
  autoload :Normalizer, 'gh/normalizer'
  autoload :Remote,     'gh/remote'
  autoload :Response,   'gh/response'
  autoload :Stack,      'gh/stack'
  autoload :Wrapper,    'gh/wrapper'
end
