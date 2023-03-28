require 'spec_helper'

describe GH::Cache do
  subject(:cache) { described_class.new }

  before { cache.backend = GH::MockBackend.new }

  it 'send HTTP requests for uncached resources' do
    expect(cache['users/rkh']['name']).to eql('Konstantin Haase')
    expect(requests.count).to be(1)
  end

  it 'uses the cache for subsequent requests' do
    expect(cache['users/rkh']['name']).to eql('Konstantin Haase')
    expect(cache['users/svenfuchs']['name']).to eql('Sven Fuchs')
    expect(cache['users/rkh']['name']).to eql('Konstantin Haase')
    expect(requests.count).to be(2)
  end

  it 'cache is resettable' do
    expect(cache['users/rkh']['name']).to eql('Konstantin Haase')
    expect(cache['users/rkh']['name']).to eql('Konstantin Haase')
    expect(requests.count).to be(1)

    cache.reset
    expect(requests.count).to be(0)
    expect(cache['users/rkh']['name']).to eql('Konstantin Haase')
    expect(requests.count).to be(1)
  end
end
