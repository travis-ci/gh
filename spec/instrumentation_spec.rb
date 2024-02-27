# frozen_string_literal: false

require 'spec_helper'

describe GH::Instrumentation do
  subject(:instrumentation) { described_class.new }

  let(:events) { [] }

  before do
    instrumentation.instrumenter = proc { |*a, &b| events << a and b[] }
    stub_request(:get, 'https://api.github.com/').to_return body: '{}'
  end

  it 'instruments http' do
    instrumentation.http :get, '/'
    expect(events.size).to be(1)
    expect(events.first).to eql(['http.gh', { verb: :get, url: '/', gh: instrumentation }])
  end

  it 'instruments []' do
    instrumentation['/']
    expect(events.size).to be(2)
    expect(events).to eql([
                            ['access.gh', { key: '/', gh: instrumentation }],
                            ['http.gh', { verb: :get, url: '/', gh: instrumentation }]
                          ])
  end

  it 'instruments load' do
    instrumentation.load('[]')
    expect(events.size).to be(1)
    expect(events.first).to eql(['load.gh', { data: '[]', gh: instrumentation }])
  end
end
