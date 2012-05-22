require 'spec_helper'

describe GH::Pagination do
  before { subject.backend = GH::MockBackend.new }

  it 'paginates' do
    counter = subject['users/rkh/repos'].map { 1 }.reduce(:+) # map/reduce!
    counter.should be > 120
  end

  it 'paginates with GH::Normalizer' do
    subject.backend = GH::Normalizer.new subject.backend
    counter = subject['users/rkh/repos'].map { 1 }.reduce(:+) # map/reduce!
    counter.should be > 120
  end

  it 'paginates on default stack' do
    counter = GH['users/rkh/repos'].map { 1 }.reduce(:+) # map/reduce!
    counter.should be > 120
  end

  it 'gives random access' do
    data = subject['users/rkh/repos']
    data.each_with_index do |value, index|
      data[index].should be == value
    end
  end
end
