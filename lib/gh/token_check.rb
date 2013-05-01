require 'gh/error'
require 'base64'

module GH
  class TokenCheck < Wrapper
    attr_accessor :client_id, :client_secret, :token

    def setup(backend, options)
      @client_secret = options[:client_secret]
      @client_id     = options[:client_id]
      @token         = options[:token]
      @check_token   = true
      super
    end

    def check_token
      return unless @check_token and client_id and client_secret and token
      auth_header = "Basic %s" % Base64.encode64("#{client_id}:#{client_secret}").gsub("\n", "")
      http :head, "/applications/#{client_id}/tokens/#{token}", "Authorization" => auth_header
      @check_token = false
    rescue GH::Error(:response_status => 404) => error
      raise GH::TokenInvalid, error
    end

    def fetch_resource(*)
      check_token
      super
    end
  end
end
