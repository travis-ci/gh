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
          requests  = envs.map { |env| env[:adapter].create_request(env) }
          responses = http.pipeline(url, requests)
          envs.zip(responses) do |e,r|
            e[:adapter].save_response(e, r.code.to_i, r.body) { |h| r.each_header { |k,v| h[k] = v } }
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
