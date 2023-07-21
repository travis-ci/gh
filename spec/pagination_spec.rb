# frozen_string_literal: true

require 'spec_helper'

describe GH::Pagination do
  subject(:pagination) { described_class.new }

  before { pagination.backend = GH::MockBackend.new }

  it 'paginates' do
    counter = pagination['users/rkh/repos'].sum { 1 } # map/reduce!
    expect(counter).to be > 120
  end

  it 'paginates with GH::Normalizer' do
    pagination.backend = GH::Normalizer.new pagination.backend
    counter = pagination['users/rkh/repos'].sum { 1 } # map/reduce!
    expect(counter).to be > 120
  end

  it 'paginates on default stack' do
    counter = GH['users/rkh/repos'].sum { 1 } # map/reduce!
    expect(counter).to be > 120
  end

  it 'gives random access' do
    data = pagination['users/rkh/repos']
    data.each_with_index do |value, index|
      expect(data[index]).to eql(value)
    end
  end

  it 'does not wrap hash responses' do
    expect(pagination['users/rkh']).not_to be_a(GH::Pagination::Paginated)
  end
end
