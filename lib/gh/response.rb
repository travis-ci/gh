require 'gh'
require 'multi_json'

module GH
  # Public: Class wrapping low level Github responses.
  #
  # Delegates safe methods to the parsed body (expected to be an Array or Hash).
  class Response
    # Internal: Content-Type header value expected from Github
    CONTENT_TYPE = "application/json; charset=utf-8"

    include Enumerable
    attr_accessor :headers, :data, :body

    # subset of safe methods that both Array and Hash implement
    extend Forwardable
    def_delegators(:@data, :[], :assoc, :each, :empty?, :flatten, :include?, :index, :inspect, :length,
      :pretty_print, :pretty_print_cycle, :rassoc, :select, :size, :to_a, :values_at)

    # Internal: Initializes a new instance.
    #
    # headers - HTTP headers as a Hash
    # body    - HTTP body as a String
    def initialize(headers, body)
      @headers = Hash[headers.map { |k,v| [k.downcase, v] }]
      raise ArgumentError, "unexpected Content-Type #{content_type}" unless content_type == CONTENT_TYPE

      @body = body.to_str
      @body = @body.encode("utf-8") if @body.respond_to? :encode
      @data = MultiJson.decode(@body)
    end

    # Public: Duplicates the instance. Will also duplicate some instance variables to behave as expected.
    #
    # Returns new Response instance.
    def dup
      super.dup_ivars
    end

    # Public: Returns the Response body as a String.
    def to_s
      @body.dup
    end

    protected

    def dup_ivars
      @headers, @data, @body = @headers.dup, @data.dup, @body.dup
      self
    end

    private

    def content_type
      headers['content-type']
    end
  end
end
