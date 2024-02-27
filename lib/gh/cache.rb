# frozen_string_literal: true

require 'gh'

module GH
  # Public: This class caches responses.
  class Cache < Wrapper
    # Public: Get/set cache to use. Compatible with Rails/ActiveSupport cache.
    attr_accessor :cache

    # Internal: Simple in-memory cache basically implementing a copying GC.
    class SimpleCache
      # Internal: Initializes a new SimpleCache.
      #
      # size - Number of objects to hold in cache.
      def initialize(size = 2048)
        @old = {}
        @new = {}
        @size = size / 2
        @mutex = Mutex.new
      end

      # Internal: Tries to fetch a value from the cache and if it doesn't exist, generates it from the
      # block given.
      def fetch(key)
        if @new.size > @size
          @mutex.synchronize do
            if @new.size > @size
              @old = @new
              @new = {}
            end
          end
        end
        @new[key] ||= @old[key] || yield
      end

      # Internal: ...
      def clear
        @mutex.synchronize do
          @old = {}
          @new = {}
        end
      end
    end

    # Internal: Initializes a new Cache instance.
    def setup(*)
      # self.cache ||= Rails.cache if defined? Rails.cache and defined? RAILS_CACHE
      # self.cache ||= ActiveSupport::Cache.lookup_store if defined? ActiveSupport::Cache.lookup_store
      self.cache ||= SimpleCache.new
      super
    end

    # Public: ...
    def reset
      super
      clear_partial or clear_all
    end

    private

    def fetch_resource(key)
      cache.fetch(prefixed(key)) { super }
    end

    def clear_partial
      return false unless cache.respond_to? :delete_matched

      pattern = '^' << Regexp.escape(prefixed(''))
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
