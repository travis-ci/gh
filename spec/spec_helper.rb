require 'yaml'
require 'fileutils'
require 'webmock/rspec'
require 'simplecov'
require 'simplecov-console'

require 'gh'

RUBY_ENGINE = 'ruby'.freeze unless defined? RUBY_ENGINE

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::HTMLFormatter
  ]
)

# Code Coverage check
SimpleCov.start do
  add_filter 'spec'
end

module GH
  module TestHelpers
    def backend(layer = subject)
      return layer if layer.backend.nil? || layer.is_a?(MockBackend)

      backend layer.backend
    end

    def requests
      backend.requests
    end

    def data
      backend.data
    end

    def expect_to_request(num = 1)
      was = requests.count
      yield
      expect(requests.count - was).to eql(num)
    end

    def expect_not_to_request(&block)
      expect_to_request(0, &block)
    end

    def load_response_stub(name)
      File.read(File.expand_path("../response_stubs/#{name}.json", __FILE__))
    end
  end

  class MockBackend < Wrapper
    attr_accessor :data, :requests

    def setup(*)
      @data = {}
      @requests = []
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
      name.gsub(/[?=&]/, '_')
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
