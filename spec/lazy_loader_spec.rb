# frozen_string_literal: true

require 'spec_helper'

describe GH::LazyLoader do
  subject(:lazy_loader) { described_class.new }

  before { lazy_loader.backend = GH::Normalizer.new(GH::MockBackend.new) }

  let! :raw do
    hash = lazy_loader.backend['users/rkh'].to_hash
    hash.delete 'name'
    hash
  end

  let :rkh do
    lazy_loader.load(raw)
  end

  it 'wraps normalizer by default' do
    expect(described_class.new.backend).to be_a(GH::Normalizer)
  end

  it 'send http requests for missing fields' do
    (expect_to_request(1) { expect(rkh['name']).to eql('Konstantin Haase') })
  end

  it 'does not send http requests for existing fields' do
    expect_not_to_request { expect(rkh['login']).to eql('rkh') }
  end

  it 'allows traversing into nested structures' do
    sven = lazy_loader.backend['users/svenfuchs'].to_hash
    sven['friends'] = [raw]
    sven.delete 'name'

    sven = lazy_loader.load(sven)
    expect_to_request(1) { expect(sven['friends'][0]['name']).to eql('Konstantin Haase') }
  end

  it 'does not request twice if the field does not exist upstream' do
    expect_to_request(1) { 2.times { rkh['foo'] } }
  end

  it 'does not skip an already existing default proc' do
    count = 0
    raw.default_proc = proc { |_hash, key| count += 1 if key == 'foo' }
    rkh = lazy_loader.load(raw)

    expect_not_to_request do
      expect(rkh['foo']).to be(1)
      expect(rkh['foo']).to be(2)
    end
  end

  it 'is still loading missing fields, even if a default proc is set' do
    count = 0
    raw.default_proc = proc { |_hash, key| count += 1 if key == 'foo' }
    rkh = lazy_loader.load(raw)

    expect_to_request 1 do
      expect(rkh['foo']).to be(1)
      expect(rkh['name']).to eql('Konstantin Haase')
      expect(rkh['foo']).to be(2)
    end
  end
end
