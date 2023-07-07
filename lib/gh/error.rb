# frozen_string_literal: true

require 'gh'

module GH
  class Error < StandardError
    attr_reader :info

    def initialize(error = nil, payload = nil, info = {})
      super(error)

      info = info.merge(error.info) if error.respond_to?(:info) && error.info.is_a?(Hash)
      error = error.error while error.respond_to? :error
      @info = info.merge(error:, payload:)

      return unless error

      set_backtrace error.backtrace if error.respond_to? :backtrace
      return unless error.respond_to?(:response) && error.response

      case response = error.response
      when Hash
        @info[:response_status] = response[:status]
        @info[:response_headers] = response[:headers]
        @info[:response_body] = response[:body]
      when Faraday::Response
        @info[:response_status] = response.status
        @info[:response_headers] = response.headers
        @info[:response_body] = response.body
      else
        @info[:response] = response
      end
    end

    def payload
      info[:payload]
    end

    def error
      info[:error]
    end

    def message
      (['GH request failed'] + info.map { |k, v| entry(k, v) }).join("\n")
    end

    private

    def entry(key, value)
      value = "#{value.class}: #{value.message}" if value.is_a?(Exception)
      value = value.inspect unless value.is_a?(String)
      value.gsub!(/"Basic .+"|(client_(?:id|secret)=)[^&\s]+/, '\1[removed]')
      "#{key}: ".ljust(20) + value
    end
  end

  class TokenInvalid < Error
  end

  def self.Error(conditions)
    Module.new do
      define_singleton_method(:===) do |exception|
        return false unless exception.is_a?(Error) && !exception.info.nil?

        # rubocop:disable Style/CaseEquality
        conditions.all? { |k, v| v === exception.info[k] }
        # rubocop:enable Style/CaseEquality
      end
    end
  end
end
