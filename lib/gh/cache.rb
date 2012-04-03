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
        @mutex.synchronize { @old, @new = @new, {} if @new.size > @size } if @new.size > @size
        @new[key] ||= @old[key] || yield
      end

      # Internal: ...
      def clear
        @mutex.synchronize { @old, @new = {}, {} }
      end
    end

    # Internal: Initializes a new Cache instance.
    def setup(*)
      self.cache ||= Rails.cache if defined? Rails.cache and defined? RAILS_CACHE
      self.cache ||= ActiveSupport::Cache.lookup_store if defined? ActiveSupport::Cache.lookup_store
      self.cache ||= SimpleCache.new
      super
    end

    # Public: ...
    def reset
      super
      clear_partial or clear_all
    end

    # Public: Retrieves resources from Github and caches response for future access.
    #
    # Examples
    #
    #   Github::Cache.new['users/rkh'] # => { ... }
    #
    # Returns the Response.
    def [](key)
      cache.fetch(prefixed(key)) { super }
    end

    private

    def clear_partial
      return false unless cache.respond_to? :delete_matched
      pattern = "^" << Regexp.escape(prefixed(""))
      cache.delete_matched Regexp.new(pattern)
      true
    rescue NotImplementedError
      false
    end

    def clear_all
      cache.clear
    end
  end
end
