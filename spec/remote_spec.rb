require 'spec_helper'

describe GH::Remote do
  it 'loads resources from github' do
    stub_request(:get, "https://api.github.com/foo").to_return(:body => '["foo"]')
    subject['foo'].to_s.should be == '["foo"]'
  end

  it 'sets headers correctly' do
    stub_request(:get, "https://api.github.com/foo").to_return(:headers => { 'X-Foo' => 'bar' }, :body => '[]')
    subject['foo'].headers['x-foo'].should be == 'bar'
  end

  it 'raises an exception for missing resources' do
    stub_request(:get, "https://api.github.com/foo").to_return(:status => 404)
    expect { subject['foo'] }.to raise_error(GH::Error)
  end

  it 'includes the request payload in errors' do
    stub_request(:post, "https://api.github.com/foo").to_return(:status => 422)
    expect { subject.post('foo', :foo => "bar") }.to raise_error { |error| error.message.should =~ /\{\s*"foo":\s*"bar"\s*\}/ }
  end

  it 'parses the body' do
    stub_request(:get, "https://api.github.com/foo").to_return(:body => '{"foo":"bar"}')
    subject['foo']['foo'].should be == 'bar'
  end

  it 'sends http calls through the frontend' do
    wrapper = Class.new(GH::Wrapper).new
    wrapper.should_receive(:http).with(:get, "/foo", backend.headers).and_return GH::Response.new
    wrapper['foo']
  end

  it 'sends request calls through the frontend' do
    wrapper = Class.new(GH::Wrapper).new
    wrapper.should_receive(:request).with(:delete, "/foo", nil).and_return GH::Response.new
    wrapper.delete '/foo'
  end

  it 'loads resources from github' do
    stub_request(:get, "https://api.github.com/foo").with(:headers => { "Accept" => "application/vnd.github.v3+json,application/json" }).to_return(:body => '["foo"]')
    GH::Remote.new(:accept => "application/vnd.github.v3+json,application/json")['foo'].to_s.should be == '["foo"]'
  end

  describe :path_for do
    subject { GH::Remote.new }
    before { subject.setup("http://localhost/api/v3", {}) }
    example { subject.path_for("foo").should be == "/api/v3/foo" }
    example { subject.path_for("/foo").should be == "/api/v3/foo" }
    example { subject.path_for("/api/v3/foo").should be == "/api/v3/foo" }
    example { subject.path_for("http://localhost/api/v3/foo").should be == "/api/v3/foo" }
  end
end
