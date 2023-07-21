# frozen_string_literal: false

require 'spec_helper'

describe GH do
  it 'allows doing requests right from the GH object' do
    expect(described_class['users/rkh']['name']).to eql('Konstantin Haase')
  end

  it 'allows posting to github' do
    stub_request(:post, 'https://api.github.com/somewhere')
      .with(body: '{"foo":"bar"}').to_return(status: 200, body: '{"hi": "ho"}', headers: {})
    response = described_class.post 'somewhere', 'foo' => 'bar'
    expect(response['hi']).to eql('ho')
  end

  describe 'with' do
    it 'returns the GH instance if no block is given' do
      expect(described_class.with(token: '...')).to be_a(GH::Wrapper)
    end

    it 'returns the block value if block is given' do
      expect(described_class.with(token: '...') { 42 }).to be(42)
    end

    it 'propagates options' do
      described_class.with(a: :b) do
        described_class.with(b: :c) do
          expect(described_class.options).to eq(a: :b, b: :c)
        end
      end
    end
  end
end
