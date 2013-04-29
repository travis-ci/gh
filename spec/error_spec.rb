require 'spec_helper'

describe GH::Error do
  class SomeWrapper < GH::Wrapper
    double_dispatch
    def modify_hash(*)
      raise "foo"
    end
  end

  let(:exception) do
    begin
      SomeWrapper.new.load('foo' => 'bar')
      nil
    rescue Exception => error
      error
    end
  end

  it "wraps connection" do
    exception.should be_an(GH::Error)
  end

  it "exposes the original exception" do
    exception.error.should be_a(StandardError)
  end

  it 'keeps the payload around' do
    exception.payload.should be == {'foo' => 'bar'}
  end

  it 'works for long content' do
    error = GH::Error.new(nil, nil, 'foo' => 'a'*1000)
    expect { error.message }.not_to raise_error
  end

  it 'can be rescued by status code' do
    stub_request(:get, "https://api.github.com/missing").to_return(:status => 404)

    expect do
      begin
        GH['missing']
      rescue GH::Error(:response_status => 404)
      end
    end.not_to raise_error


    expect do
      begin
        GH['missing']
      rescue GH::Error(:response_status => 500)
      end
    end.to raise_error(GH::Error)
  end
end
