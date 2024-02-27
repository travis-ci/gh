# frozen_string_literal: true

require 'spec_helper'

xdescribe GH::TokenCheck do
  subject(:token_check) { described_class.new }

  before do
    token_check.client_id = 'foo'
    token_check.client_secret = 'bar'
    token_check.token = 'baz'
  end

  it 'adds client_id and client_secret to a request' do
    allow(token_check.backend).to receive(:http).with(:post, '/applications/foo/token',
                                                      { body: '{"access_token": "baz"}',
                                                        'Authorization' => 'Basic Zm9vOmJhcg==' }) do
      error = GH::Error.new
      error.info[:response_status] = 404
      raise error
    end
    expect { token_check['/x'] }.to raise_error(GH::TokenInvalid)
    expect(token_check.backend).to have_received(:http).with(:post, '/applications/foo/token',
                                                             body: '{"access_token": "baz"}',
                                                             'Authorization' => 'Basic Zm9vOmJhcg==')
  end

  it 'does not swallow other status codes' do
    allow(token_check.backend).to receive(:http).with(:post, '/applications/foo/token',
                                                      { body: '{"access_token": "baz"}',
                                                        'Authorization' => 'Basic Zm9vOmJhcg==' }) do
      error = GH::Error.new
      error.info[:response_status] = 500
      raise error
    end
    expect { token_check['/x'] }.to raise_error(GH::Error(response_status: 500))
    expect(token_check.backend).to have_received(:http).with(:post, '/applications/foo/token',
                                                             body: '{"access_token": "baz"}',
                                                             'Authorization' => 'Basic Zm9vOmJhcg==')
  end
end
