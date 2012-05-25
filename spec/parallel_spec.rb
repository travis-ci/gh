require 'spec_helper'

describe GH::Parallel do
  before do
    stub_request(:get, "https://api.github.com/users/rkh").to_return(:status => 200, :body => '{"name": "Konstantin Haase"}')
    stub_request(:get, "https://api.github.com/users/svenfuchs").to_return(:status => 200, :body => '{"name": "Sven Fuchs"}')
  end

  it 'allows normal requests' do
    subject['users/rkh']['name'].should be == 'Konstantin Haase'
  end

  it 'sets in_parallel?' do
    subject.should_not be_in_parallel
    subject.in_parallel do
      subject.should be_in_parallel
    end
    subject.should_not be_in_parallel
  end

  it 'runs requests in parallel' do
    a = b = nil
    subject.in_parallel do
      a = subject['users/rkh']
      b = subject['users/svenfuchs']

      expect { a['name'] }.to raise_error(RuntimeError)
      expect { b['name'] }.to raise_error(RuntimeError)
    end

    a['name'].should be == "Konstantin Haase"
    b['name'].should be == "Sven Fuchs"

    a.should respond_to('to_hash')
    b.should respond_to('to_hash')
  end

  it 'works with GH stack' do
    rkh = nil
    GH.should_not be_in_parallel
    GH.in_parallel do
      GH.should be_in_parallel
      rkh = GH['users/rkh']
      expect { rkh['name'] }.to raise_error(RuntimeError)
    end
    rkh['name'].should be == "Konstantin Haase"
    GH.should_not be_in_parallel
  end
end
