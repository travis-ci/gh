# encoding: utf-8
require 'spec_helper'

describe GH::Response do
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
