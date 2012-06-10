require 'gh'
require 'faraday'
require 'thread'
require 'net/https'
require 'net/http/pipeline'
require 'net/http/persistent'

module GH
  # Faraday adapter based on Net::HTTP, with persistent connection and pipeline support.
  class FaradayAdapter < Faraday::Adapter::NetHttpPersistent
    class Manager
      def initialize(*)
        @mutex    = Mutex.new
        @requests = {}
      end

      def add_request(http, env, adapter)
        url = env[:url] + '/'
        env[:adapter] = adapter

        @mutex.synchronize do
          @requests[url] ||= []
          @requests[url] << env
        end
      end

      def run
        requests = nil
        @mutex.synchronize { requests, @requests = @requests, {} }
        http = Net::HTTP::Persistent.new 'GH'
        requests.each do |url, envs|
          _requests = envs.map { |env| env[:adapter].create_request(env) }
          responses = http.pipeline(url, _requests)
          envs.zip(responses) do |env, http_response|
            env[:adapter].save_response(env, http_response.code.to_i, http_response.body) do |headers|
              http_response.each_header { |key, value| headers[key] = value }
            end
            env[:response].finish(env)
          end
        end
      end
    end

    self.supports_parallel = true

    def self.setup_parallel_manager(options = {})
      Manager.new(options)
    end

    def call(env)
      catch(:parallel) { super }
    end

    def perform_request(http, env)
      return super unless env[:parallel_manager]
      env[:parallel_manager].add_request(http, env, self)
      throw :parallel, @app.call(env)
    end
  end
end
