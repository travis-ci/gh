require 'gh'
require 'addressable/uri'

module GH
  # Public: Simple base class for low level layers.
  # Handy if you want to manipulate resources coming in from Github.
  #
  # Examples
  #
  #   class IndifferentAccess
  #     def [](key) super.tap { |r| r.data.with_indifferent_access! } end
  #   end
  #
  #   gh = IndifferentAccess.new
  #   gh['users/rkh'][:name] # => "Konstantin Haase"
  #
  #   # easy to use in the low level stack
  #   gh = Github.build do
  #     use GH::Cache
  #     use IndifferentAccess
  #     use GH::Normalizer
  #   end
  class Wrapper
    extend Forwardable
    include Case

    # Public: Get wrapped layer.
    attr_reader :backend

    # Public: Returns the URI used for sending out web request.
    def_delegator :backend, :api_host

    # Public: Retrieves resources from Github.
    #
    # By default, this method is delegated to the next layer on the stack
    # and modify is called.
    def [](key)
      modify backend[key]
    end

    # Internal: Get/set default layer to wrap when creating a new instance.
    def self.wraps(klass = nil)
      @wraps = klass if klass
      @wraps || Remote
    end

    # Public: Initialize a new Wrapper.
    #
    # backend - layer to be wrapped
    # options - config options
    def initialize(backend = nil, options = {})
      setup(*normalize_options(backend, options))
      options.each_pair { |key, value| public_send("#{key}=", value) if respond_to? "#{key}=" }
    end

    # Public: Set wrapped layer.
    def backend=(layer)
      layer.frontend = self
      @backend = layer
    end

    # Internal: ...
    def frontend=(value)
      @frontend = value
    end

    # Internal: ...
    def frontend
      @frontend ? @frontend.frontend : self
    end

    def inspect
      "#<#{self.class}: #{backend.inspect}>"
    end

    private

    def self.double_dispatch
      define_method(:modify) { |data| double_dispatch(data) }
    end

    def double_dispatch(data)
      case data
      when respond_to(:to_gh)   then modify_response(data)
      when respond_to(:to_hash) then modify_hash(data)
      when respond_to(:to_ary)  then modify_array(data)
      when respond_to(:to_str)  then modify_string(data)
      when respond_to(:to_int)  then modify_integer(data)
      else raise ArgumentError, "cannot dispatch #{data.inspect}"
      end
    end

    def modify_response(response)
      result = double_dispatch response.data
      result.respond_to?(:to_gh) ? result.to_gh : Response.new({}, result)
    end

    def modify(data, *)
      data
    end

    alias modify_array    modify
    alias modify_hash     modify
    alias modify_string   modify
    alias modify_integer  modify

    def setup(backend, options)
      self.backend = Wrapper === backend ? backend : self.class.wraps.new(backend, options)
    end

    def normalize_options(backend, options)
      backend, options = nil, backend if Hash === backend
      options ||= {}
      backend ||= options[:backend] || options[:api_url] || 'https://api.github.com'
      [backend, options]
    end

    def full_url(key)
      api_host + path_for(key)
    end

    def path_for(key)
      uri = Addressable::URI.parse(key)
      raise ArgumentError, "URI out of scope: #{key}" if uri.host and uri.host != api_host.host
      uri.request_uri
    end
  end
end
