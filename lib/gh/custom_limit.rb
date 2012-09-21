module GH
  # Adds Client info so even unauthenticated requests can use a custom request limit
  class CustomLimit < Wrapper
    attr_accessor :client_id, :client_secret

    def setup(backend, options)
      @client_id     = options[:client_id]
      @client_secret = options[:client_secret]
      super
    end

    def fetch_resource(key)
      return super unless client_id

      url    = full_url(key)
      params = url.query_values || {}

      unless params.include? 'client_id'
        params['client_id']     = client_id
        params['client_secret'] = client_secret
      end

      url.query_values = params
      super url.request_uri
    end
  end
end
