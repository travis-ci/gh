require 'spec_helper'

describe GH::Pagination do
  before { subject.backend = GH::Pagination.new(GH::MockBackend.new) }

  it 'paginates' do
    counter = subject['users/rkh/repos'].map { 1 }.reduce(:+) # map/reduce!
    counter.should be > 120
  end
end
