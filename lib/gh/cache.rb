require 'gh'
require 'thread'

module GH
  # Public: This class deals with HTTP requests to Github. It is the base Wrapper you always want to use.
  # Note that it is usually used implicitely by other wrapper classes if not specified.
  class Cache < Wrapper
    # Public: Get/set cache to use. Compatible with Rails/ActiveSupport cache.
    attr_accessor :cache

    # Internal: Simple in-memory cache basically implementing a copying GC.
    class SimpleCache
      # Internal: Initializes a new SimpleCache.
      #
      # size - Number of objects to hold in cache.
      def initialize(size = 2048)
        @old, @new, @size, @mutex = {}, {}, size/2, Mutex.new
      end

      # Internal: Tries to fetch a value from the cache and if it doesn't exist, generates it from the
      # block given.
      def fetch(key)
        @mutex.lock { @old, @new = @new, {} if @new.size > @size } if @new.size > @size
        @new[key] ||= @old[key] || yield
      end
    end

    # Public: Initializes a new Cache instance.
    #
    # backend - Backend to wrap (defaults to Remote)
    # options - Configuration options:
    #           :cache - Cache to be used.
    def initialize(*)
      super
      self.cache ||= Rails.cache if defined? Rails.cache
      self.cache ||= ActiveSupport::Cache.lookup_store if defined? ActiveSupport::Cache.lookup_store
      self.cache ||= SimpleCache.new
    end

    # Public: Retrieves resources from Github and caches response for future access.
    #
    # Examples
    #
    #   Github::Cache.new['users/rkh'] # => { ... }
    #
    # Returns the Response.
    def [](key)
      cache.fetch(path_for(key)) { super }
    end
  end
end
