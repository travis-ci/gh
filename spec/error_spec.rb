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
    exception.error.should be_a(RuntimeError)
  end

  it 'keeps the payload around' do
    exception.payload.should be == {'foo' => 'bar'}
  end
end
