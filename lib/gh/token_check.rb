require 'gh/error'

module GH
  class TokenCheck < Wrapper
    attr_accessor :client_id, :token

    def setup(backend, options)
      @client_id   = options[:client_id]
      @token       = options[:token]
      @check_token = true
      super
    end

    def check_token
      return unless @check_token and client_id and token
      http :head, "/applications/#{client_id}/tokens/#{token}"
      @check_token = false
    rescue GH::Error
      raise GH::TokenInvalid
    end

    def fetch_resource(*)
      check_token
      super
    end
  end
end
