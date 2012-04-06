require 'spec_helper'

describe GH::LazyLoader do
  before { subject.backend = GH::Normalizer.new(GH::MockBackend.new) }

  let! :raw do
    hash = subject.backend['users/rkh'].to_hash
    hash.delete 'name'
    hash
  end

  let :rkh do
    subject.load(raw)
  end

  it 'wraps normalizer by default' do
    GH::LazyLoader.new.backend.should be_a(GH::Normalizer)
  end

  it 'send http requests for missing fields' do
    should_request(1) { rkh['name'].should be == 'Konstantin Haase' }
  end

  it 'does not send http requests for existing fields' do
    should_not_request { rkh['login'].should be == 'rkh' }
  end

  it 'allows traversing into nested structures' do
    sven = subject.backend['users/svenfuchs'].to_hash
    sven['friends'] = [raw]
    sven.delete 'name'

    sven = subject.load(sven)
    should_request(1) { sven['friends'][0]['name'].should be == 'Konstantin Haase' }
  end

  it 'does not request twice if the field does not exist upstream' do
    should_request(1) { 2.times { rkh['foo'] } }
  end

  it 'does not skip an already existing default proc' do
    count = 0
    raw.default_proc = proc { |hash, key| count += 1 if key == 'foo' }
    rkh = subject.load(raw)

    should_not_request do
      rkh['foo'].should be == 1
      rkh['foo'].should be == 2
    end
  end

  it 'is still loading missing fields, even if a default proc is set' do
    count = 0
    raw.default_proc = proc { |hash, key| count += 1 if key == 'foo' }
    rkh = subject.load(raw)

    should_request 1 do
      rkh['foo'].should be == 1
      rkh['name'].should be == 'Konstantin Haase' 
      rkh['foo'].should be == 2
    end
  end
end
