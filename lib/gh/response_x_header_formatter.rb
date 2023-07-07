# frozen_string_literal: true

require 'faraday/logging/formatter'

module GH
  class ResponseXHeaderFormatter < Faraday::Logging::Formatter
    def request(env); end

    def response(env)
      info('Response') { env.response_headers.select { |k, _v| k =~ /^x-/ }.sort.to_h }
    end
  end
end
