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

  def self.[](key)
    backend = Thread.current[:GH] ||= DefaultStack.build
    backend[key]
  end

  def self.with(backend)
    backend = DefaultStack.build(backend) if Hash === backend
    was, Thread.current[:GH] = Thread.current[:GH], backend
    yield
  ensure
    Thread.current[:GH] = was
  end

  DefaultStack = Stack.new do
    use Cache
    use Normalizer
    use Remote
  end
end
