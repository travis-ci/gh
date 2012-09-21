require 'gh'

module GH
  class Error < Exception
    attr_reader :info

    def initialize(error = nil, payload = nil, info = {})
      info   = info.merge(error.info) if error.respond_to? :info and Hash === error.info
      error  = error.error while error.respond_to? :error
      @info  = info.merge(error: error, payload: payload)
      set_backtrace error.backtrace if error
    end

    def payload
      info[:payload]
    end

    def error
      info[:error]
    end

    def message
      "GH request failed\n" + info.map { |k,v| entry(k,v) }.join("\n")
    end

    private

    def entry(key, value)
      value = "#{value.class}: #{value.message}" if Exception === value
      value = value.inspect unless String === value
      value = value.gsub(/[^\n]{80}/, "\\0\n").lines.map { |l| "\n    #{l}" }.join.gsub(/\n+/, "\n")
      (key.to_s + ": ").ljust(12) + value
    end
  end
end
