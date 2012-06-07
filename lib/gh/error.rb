require 'gh'

module GH
  class Error < Exception
    attr_reader :error, :payload

    def self.new(error, *)
      Error === error ? error : super
    end

    def initialize(error = nil, payload = nil)
      error = error.error while error.respond_to? :error
      @error, @payload = error, payload
      set_backtrace error.backtrace if error
    end

    def message
      "GH request failed (#{error.class}: #{error.message}) with payload: #{short(payload.inspect)}"
    end

    private

    def short(string)
      string.length < 101 ? string : string[0,97] + '...'
    end
  end
end
