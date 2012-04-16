require 'spec_helper'

describe GH::Instrumentation do
  before do
    @events = []
    subject.instrumenter = proc { |*a, &b| @events << a and b[] }
    stub_request(:get, "https://api.github.com/").to_return :body => "{}"
  end

  it 'instruments http' do
    subject.http :get, '/'
    @events.size.should be == 1
    @events.first.should be == ['http.gh', :verb => :get, :url => '/', :gh => subject]
  end

  it 'instruments []' do
    subject['/']
    @events.size.should be == 2
    @events.should be == [
      ['access.gh', :key => '/', :gh => subject],
      ['http.gh', :verb => :get, :url => '/', :gh => subject]
    ]
  end

  it 'instruments load' do
    subject.load("[]")
    @events.size.should be == 1
    @events.first.should be == ['load.gh', :data => "[]", :gh => subject]
  end
end
