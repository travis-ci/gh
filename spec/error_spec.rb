require 'spec_helper'

class SomeWrapper < GH::Wrapper
  double_dispatch

  def modify_hash(*)
    raise 'foo'
  end
end

describe GH::Error do
  let(:exception) do
    begin
      SomeWrapper.new.load('foo' => 'bar')
      nil
    rescue => e
      e
    end
  end

  it 'wraps connection' do
    expect(exception).to be_an(described_class)
  end

  it 'exposes the original exception' do
    expect(exception.error).to be_a(StandardError)
  end

  it 'keeps the payload around' do
    expect(exception.payload).to eq('foo' => 'bar')
  end

  it 'works for long content' do
    error = described_class.new(nil, nil, 'foo' => 'a' * 1000)
    expect { error.message }.not_to raise_error
  end

  it 'can be rescued by status code' do
    stub_request(:get, 'https://api.github.com/missing?per_page=100').to_return(status: 404)

    expect do
      begin
        GH['missing']
      rescue GH::Error(response_status: 404) => e
        e
      end
    end.not_to raise_error

    expect do
      begin
        GH['missing']
      rescue GH::Error(response_status: 500) => e
        e
      end
    end.to raise_error(described_class)
  end
end
