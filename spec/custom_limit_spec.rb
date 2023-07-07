# frozen_string_literal: true

require 'spec_helper'

describe GH::CustomLimit do
  let(:custom_limit) { described_class.new }

  before do
    custom_limit.client_id = 'foo'
    custom_limit.client_secret = 'bar'
  end

  it 'adds client_id and client_secret to a request' do
    headers = {
      'User-Agent' => "GH/#{GH::VERSION}",
      'Accept' => 'application/vnd.github.v3+json',
      'Accept-Charset' => 'utf-8'
    }

    allow(custom_limit).to receive(:http).with(:get, '/x?client_id=foo&client_secret=bar', headers)
                                         .and_return(GH::Response.new)
    custom_limit['/x']
    expect(custom_limit).to have_received(:http).with(:get, '/x?client_id=foo&client_secret=bar', headers)
  end
end
