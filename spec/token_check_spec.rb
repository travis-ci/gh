require 'spec_helper'

describe GH::TokenCheck do
  before do
    subject.client_id     = 'foo'
    subject.client_secret = 'bar'
    subject.token         = 'baz'
  end

  it 'adds client_id and client_secret to a request' do
    subject.backend.should_receive(:http).with(:post, "/applications/foo/token?access_token=baz", "Authorization" => "Basic Zm9vOmJhcg==") do
      error = GH::Error.new
      error.info[:response_status] = 404
      raise error
    end
    expect { subject['/x'] }.to raise_error(GH::TokenInvalid)
  end

  it 'does not swallow other status codes' do
    pending "test needs rewrite for newer RSpec"
    subject.backend.should_receive(:http).with(:post, "/applications/foo/token?access_token=baz", "Authorization" => "Basic Zm9vOmJhcg==") do
      error = GH::Error.new
      error.info[:response_status] = 500
      raise error
    end
    expect { subject['/x'] }.not_to raise_error
  end
end
