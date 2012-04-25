require 'gh'

module GH
  class Error < Exception
    attr_reader :error, :payload

    def initialize(error = nil, payload = nil)
      error = error.error while error.respond_to? :error
      @error, @payload = error, payload
      set_backtrace error.backtrace if error
    end

    def message
      "GH request failed (#{error.message}) with payload: #{payload.inspect}"
    end
  end
end
