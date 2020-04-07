require 'spec_helper'

describe GH::TokenCheck do
  before do
    subject.client_id     = 'foo'
    subject.client_secret = 'bar'
    subject.token         = 'baz'
  end

  it 'adds client_id and client_secret to a request' do
    expect(subject.backend).to receive(:http).with(:post, "/applications/foo/token", :body => "{\"access_token\": \"baz\"}", "Authorization" => "Basic Zm9vOmJhcg==") do
      error = GH::Error.new
      error.info[:response_status] = 404
      raise error
    end
    expect { subject['/x'] }.to raise_error(GH::TokenInvalid)
  end

  it 'does not swallow other status codes' do
    expect(subject.backend).to receive(:http).with(:post, "/applications/foo/token", :body => "{\"access_token\": \"baz\"}", "Authorization" => "Basic Zm9vOmJhcg==") do
      error = GH::Error.new
      error.info[:response_status] = 500
      raise error
    end
    expect { subject['/x'] }.to raise_error(GH::Error(:response_status => 500))
  end
end
