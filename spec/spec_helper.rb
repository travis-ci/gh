require 'gh'
require 'webmock/rspec'
require 'yaml'
require 'fileutils'

RUBY_ENGINE = 'ruby' unless defined? RUBY_ENGINE

module GH
  module TestHelpers
    def backend(layer = subject)
      return layer if layer.backend.nil? or layer.is_a? MockBackend
      backend layer.backend
    end

    def requests
      backend.requests
    end

    def data
      backend.data
    end

    def should_request(num = 1, &block)
      was = requests.count
      yield
      (requests.count - was).should be == num
    end

    def should_not_request(&block)
      should_request(0, &block)
    end

  end

  class MockBackend < Wrapper
    attr_accessor :data, :requests

    def setup(*)
      @data, @requests = {}, []
      super
    end

    def fetch_resource(key)
      key = path_for(key)
      key_fn = sanitize_filename(key)
      file = File.expand_path("../payloads/#{key_fn}.yml", __FILE__)
      @requests << key
       result = @data[key] ||= begin
        unless File.exist? file
          res = allow_http { super }
          FileUtils.mkdir_p File.dirname(file)
          File.write file, [res.headers, res.body].to_yaml
        end

        headers, body = YAML.load_file(file)
        Response.new(body, headers, frontend.full_url(key))
      end

      result = Response.new(result) unless result.is_a? Response
      result
    end

    def sanitize_filename(name)
      name.gsub(/[\?=&]/,"_")
    end

    def reset
      super
      @data.clear
      @requests.clear
    end

    private

    def allow_http
      WebMock.allow_net_connect!
      yield
    ensure
      WebMock.disable_net_connect!
    end
  end
end

RSpec.configure do |c|
  c.include GH::TestHelpers
  c.before { GH::DefaultStack.replace GH::Remote, GH::MockBackend }
  c.after { GH.reset }
end
