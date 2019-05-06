# encoding: utf-8
require 'spec_helper'

describe GH::Response do
  let(:response) { File.read(File.expand_path('../node_contents.json', __FILE__)) }

  before do
    stub_request(:get, '/repos/travis-ci/gh/contents/README.md?per_page=100').to_return(status: 200, body: response)
  end

  it 'parses content endpoints correctly' do
    GH['/repos/travis-ci/gh/contents/README.md']
  end

  it 'handles UTF-8 properly, even if encoded binary' do
    raw = '{"foo":"über cool sista året"}'
    raw.force_encoding 'binary' if raw.respond_to? :force_encoding
    response = GH::Response.new(raw)
    response['foo'].should be == 'über cool sista året'
  end

  # it 'handles broken encodings properly' do
  #   GH::Response.new("{\"foo\":\"\xC3\"}")["foo"].should be == "\xC3"
  # end
end
