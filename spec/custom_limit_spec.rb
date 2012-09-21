require 'spec_helper'

describe GH::CustomLimit do
  before do
    subject.client_id     = 'foo'
    subject.client_secret = 'bar'
  end

  it 'adds client_id and client_secret to a request' do
    subject.backend.
      should_receive(:fetch_resource).
      with('/x?client_id=foo&client_secret=bar').
      and_return(GH::Response.new)
    subject['/x']
  end
end
