require 'spec_helper'

describe GH::LinkFollower do
  subject(:link_follower) { described_class.new }

  before { link_follower.backend = GH::Normalizer.new(GH::MockBackend.new) }

  let(:pull_request) { link_follower['/repos/sinatra/sinatra/pulls/56'] }
  let(:comments) { pull_request['comments'] }
  let(:comment) { comments.first }
  let(:commentator) { comment['owner'] }

  it 'follows links' do
    expect(commentator['login']).to eql('rtomayko')
  end

  it 'works with lazy loading' do
    link_follower.backend = GH::LazyLoader.new(link_follower.backend)
    # location is not included in the comment payload
    expect(commentator['location']).to eql('San Francisco')
  end

  it 'does not raise exceptions for unknown fields' do
    expect(commentator['location']).to be_nil
  end
end
