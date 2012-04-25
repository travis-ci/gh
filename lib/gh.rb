require 'gh/version'
require 'backports'
require 'forwardable'

module GH
  autoload :Cache,            'gh/cache'
  autoload :Case,             'gh/case'
  autoload :Error,            'gh/error'
  autoload :Instrumentation,  'gh/instrumentation'
  autoload :LazyLoader,       'gh/lazy_loader'
  autoload :LinkFollower,     'gh/link_follower'
  autoload :MergeCommit,      'gh/merge_commit'
  autoload :Normalizer,       'gh/normalizer'
  autoload :Remote,           'gh/remote'
  autoload :Response,         'gh/response'
  autoload :ResponseWrapper,  'gh/response_wrapper'
  autoload :Stack,            'gh/stack'
  autoload :Wrapper,          'gh/wrapper'

  def self.with(backend)
    backend = DefaultStack.build(backend) if Hash === backend
    was, self.current = current, backend
    yield
  ensure
    self.current = was
  end

  def self.current
    Thread.current[:GH] ||= DefaultStack.new
  end

  def self.current=(backend)
    Thread.current[:GH] = backend
  end

  extend SingleForwardable
  def_delegators :current, :api_host, :[], :reset, :load, :post

  DefaultStack = Stack.new do
    use Instrumentation
    use LinkFollower
    use MergeCommit
    use LazyLoader
    use Cache
    use Normalizer
    use Remote
  end
end
