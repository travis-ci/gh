require 'spec_helper'

describe GH::Response do
  let(:body) { load_response_stub('node_contents') }

  before do
    stub_request(:get, 'https://api.github.com/repos/travis-ci/gh/contents/README.md?per_page=100').to_return(
      status: 200,
      body: body
    )
  end

  it 'parses content endpoints correctly' do
    response = GH['/repos/travis-ci/gh/contents/README.md']
    parsed_body = JSON.parse(body)

    expect(response['name']).to eql(parsed_body['name'])
    expect(response['path']).to eql(parsed_body['path'])
    expect(response['size']).to eql(parsed_body['size'])
  end

  it 'handles UTF-8 properly, even if encoded binary' do
    raw = '{"foo":"über cool sista året"}'
    raw.force_encoding 'binary' if raw.respond_to? :force_encoding
    response = described_class.new(raw)
    expect(response['foo']).to eql('über cool sista året')
  end

  # it 'handles broken encodings properly' do
  #   expect(GH::Response.new("{\"foo\":\"\xC3\"}")["foo"]).to eql("\xC3")
  # end
end
