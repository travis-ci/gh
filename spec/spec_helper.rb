require 'gh'
require 'webmock/rspec'
require 'yaml'
require 'fileutils'

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
  end

  class MockBackend < Wrapper
    attr_accessor :data, :requests

    def setup(*)
      @data, @requests = {}, []
      super
    end

    def [](key)
      key  = path_for(key)
      file = File.expand_path("../payloads/#{key}.yml", __FILE__)
      @requests << key

      result = @data[key] ||= begin
        unless File.exist? file
          res = allow_http { super }
          FileUtils.mkdir_p File.dirname(file)
          File.write file, [res.headers, res.body].to_yaml
        end

        Response.new(*YAML.load_file(file))
      end

      result = Response.new({}, result) unless result.is_a? Response
      result
    end

    def reset
      super
      @data.clear
      @requests.clear
    end

    private

    def allow_http
      raise Faraday::Error::ResourceNotFound if ENV['CI']
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
