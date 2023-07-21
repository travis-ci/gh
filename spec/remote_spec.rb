# frozen_string_literal: false

require 'spec_helper'

describe GH::Remote do
  subject(:remote) { described_class.new }

  it 'loads resources from github' do
    stub_request(:get, 'https://api.github.com/foo').to_return(body: '["foo"]')
    expect(remote['foo'].to_s).to eql('["foo"]')
  end

  it 'sets headers correctly' do
    stub_request(:get, 'https://api.github.com/foo').to_return(headers: { 'X-Foo' => 'bar' }, body: '[]')
    expect(remote['foo'].headers['x-foo']).to eql('bar')
  end

  it 'raises an exception for missing resources' do
    stub_request(:get, 'https://api.github.com/foo').to_return(status: 404)
    expect { remote['foo'] }.to raise_error(GH::Error)
  end

  it 'includes the request payload in errors' do
    stub_request(:post, 'https://api.github.com/foo').to_return(status: 422)
    expect { remote.post('foo', foo: 'bar') }.to raise_error do |error|
      expect(error.message).to match(/\{\s*"foo":\s*"bar"\s*\}/)
    end
  end

  it 'parses the body' do
    stub_request(:get, 'https://api.github.com/foo').to_return(body: '{"foo":"bar"}')
    expect(remote['foo']['foo']).to eql('bar')
  end

  it 'sends http calls through the frontend' do
    wrapper = Class.new(GH::Wrapper).new
    allow(wrapper).to receive(:http).with(:get, '/foo', backend.headers).and_return(GH::Response.new)
    expect(wrapper['foo'].to_s).to eql('{}')
    expect(wrapper).to have_received(:http).with(:get, '/foo', backend.headers)
  end

  it 'sends request calls through the frontend' do
    wrapper = Class.new(GH::Wrapper).new
    allow(wrapper).to receive(:request).with(:delete, '/foo', nil).and_return(GH::Response.new)
    expect { wrapper.delete '/foo' }.not_to raise_error
    expect(wrapper).to have_received(:request).with(:delete, '/foo', nil)
  end

  it 'loads resources from github via API v3' do
    stub_request(:get, 'https://api.github.com/foo')
      .with(headers: { 'Accept' => 'application/vnd.github.v3+json,application/json' })
      .to_return(body: '["foo"]')
    expect(described_class.new(accept: 'application/vnd.github.v3+json,application/json')['foo'].to_s).to eql('["foo"]')
  end

  context 'when testing path_for' do
    before { remote.setup('http://localhost/api/v3', {}) }

    example { expect(remote.path_for('foo')).to eql('/api/v3/foo') }
    example { expect(remote.path_for('/foo')).to eql('/api/v3/foo') }
    example { expect(remote.path_for('/api/v3/foo')).to eql('/api/v3/foo') }
    example { expect(remote.path_for('http://localhost/api/v3/foo')).to eql('/api/v3/foo') }
  end
end
