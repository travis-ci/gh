require 'gh'
require 'faraday'

module GH
  # Public: This class deals with HTTP requests to Github. It is the base Wrapper you always want to use.
  # Note that it is usually used implicitely by other wrapper classes if not specified.
  class Remote < Wrapper
    attr_reader :api_host, :connection, :headers, :prefix

    # Public: Generates a new Rempte instance.
    #
    # api_host - HTTP host to send requests to, has to include schema (https or http)
    # options  - Hash with configuration options:
    #            :token    - OAuth token to use (optional).
    #            :username - Github user used for login (optional).
    #            :password - Github password used for login (optional).
    #            :origin   - Value of the origin request header (optional).
    #            :headers  - HTTP headers to be send on every request (optional).
    #            :adapter  - HTTP library to use for making requests (optional, default: :net_http)
    #
    # It is highly recommended to set origin, but not to set headers.
    # If you set the username, you should also set the password.
    def setup(api_host, options)
      token, username, password = options.values_at :token, :username, :password

      api_host  = api_host.api_host if api_host.respond_to? :api_host
      @api_host = Addressable::URI.parse(api_host)
      @headers  = options[:headers].try(:dup)  || {
        "User-Agent"      => options[:user_agent] || "GH/#{GH::VERSION}",
        "Accept"          => "application/vnd.github.v3+json," \
                             "application/vnd.github.beta+json;q=0.5," \
                             "application/json;q=0.1",
        "Accept-Charset"  => "utf-8",
      }

      @headers['Origin'] = options[:origin] if options[:origin]

      @prefix = ""
      @prefix << "#{token}@" if token
      @prefix << "#{username}:#{password}@" if username and password
      @prefix << @api_host.host

      faraday_options = {:url => api_host}
      faraday_options[:ssl] = options[:ssl] if options[:ssl]
      faraday_options.merge! options[:faraday_options] if options[:faraday_options]

      @connection = Faraday.new(faraday_options) do |builder|
        builder.request(:authorization, :token, token) if token
        builder.request(:basic_auth, username, password)  if username and password
        builder.request(:retry)
        builder.response(:raise_error)
        #builder.use(options[:adapter] || GH::FaradayAdapter)
        builder.adapter(:net_http)
      end
    end

    # Public: ...
    def inspect
      "#<#{self.class}: #{api_host}>"
    end

    # Internal: ...
    def fetch_resource(key)
      frontend.http(:get, frontend.path_for(key), headers)
    end

    # Internal: ...
    def generate_response(key, response)
      body, headers = response.body, response.headers
      url = response.respond_to?(:url) ? response.url : response.env.try(:[], :url)
      url = frontend.full_url(key) if url.to_s.empty?
      modify(body, headers, url)
    end

    # Internal: ...
    def http(verb, url, headers = {}, &block)
      connection.run_request(verb, url, nil, headers, &block)
    rescue Exception => error
      raise Error.new(error, nil, :verb => verb, :url => url, :headers => headers)
    end

    # Internal: ...
    def request(verb, key, body = nil)
      response = frontend.http(verb, path_for(key), headers) do |req|
        req.body = Response.new(body).to_s if body
      end
      frontend.generate_response(key, response)
    rescue GH::Error => error
      error.info[:payload] = Response.new(body).to_s if body
      raise error
    end

    # Public: ...
    def post(key, body)
      frontend.request(:post, key, body)
    end

    # Public: ...
    def delete(key)
      frontend.request(:delete, key)
    end

    # Public: ...
    def head(key)
      frontend.request(:head, key)
    end

    # Public: ...
    def patch(key, body)
      frontend.request(:patch, key, body)
    end

    # Public: ...
    def put(key, body)
      frontend.request(:put, key, body)
    end

    # Public: ...
    def reset
    end

    # Public: ...
    def load(data)
      modify(data)
    end

    # Public: ...
    def in_parallel
      raise RuntimeError, "use GH::Parallel middleware for #in_parallel support"
    end

    def full_url(key)
      uri = api_host + Addressable::URI.parse(key)
      raise ArgumentError, "URI out of scope: #{key}" if uri.host != api_host.host
      uri
    end

    def path_for(key)
      frontend.full_url(key).request_uri
    end

    private

    def identifier(key)
      path_for(key)
    end

    def modify(body, headers = {}, url = nil)
      return body if body.is_a? Response
      Response.new(body, headers, url)
    end
  end
end
