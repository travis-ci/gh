require 'spec_helper'

describe GH::CustomLimit do
  before do
    subject.client_id     = 'foo'
    subject.client_secret = 'bar'
  end

  it 'adds client_id and client_secret to a request' do
    headers = {
      "User-Agent"     => "GH/#{GH::VERSION}",
      "Accept"         => "application/vnd.github.v3+json",
      "Accept-Charset" => "utf-8"
    }

    subject.
      should_receive(:http).
      with(:get, '/x?client_id=foo&client_secret=bar', headers).
      and_return(GH::Response.new)

    subject['/x']
  end
end
