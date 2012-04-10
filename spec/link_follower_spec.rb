require 'spec_helper'

describe GH::LinkFollower do
  before { subject.backend = GH::Normalizer.new(GH::MockBackend.new) }

  let(:pull_request) { subject['/repos/sinatra/sinatra/pulls/56'] }
  let(:comments) { pull_request['comments'] }
  let(:comment) { comments.first }
  let(:commentator) { comment['owner'] }

  it 'follows links' do
    commentator['login'].should be == 'rtomayko'
  end

  it 'works with lazy loading' do
    subject.backend = GH::LazyLoader.new(subject.backend)
    # location is not included in the comment payload
    commentator["location"].should be == "San Francisco"
  end

  it 'does not raise exceptions for unknown fields' do
    commentator["location"].should be_nil
  end
end