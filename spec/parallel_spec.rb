require 'spec_helper'

describe GH::Parallel do
  before do
    stub_request(:get, "https://api.github.com/users/rkh").to_return(status: 200, body: '{"name": "Konstantin Haase"}')
    stub_request(:get, "https://api.github.com/users/svenfuchs").to_return(status: 200, body: '{"name": "Sven Fuchs"}')
    stub_request(:get, "https://api.github.com/users/rkh?per_page=100").to_return(status: 200, body: '{"name": "Konstantin Haase"}')
    stub_request(:get, "https://api.github.com/users/svenfuchs?per_page=100").to_return(status: 200, body: '{"name": "Sven Fuchs"}')
    stub_request(:get, "https://api.github.com/user/30442/repos?per_page=100&page=2").to_return(status: 200, body: load_response_stub('repos_2'))
    stub_request(:get, "https://api.github.com/users/rkh/repos?per_page=100").to_return(
      status: 200,
      body: load_response_stub('repos'),
      headers: { link: '<https://api.github.com/user/30442/repos?per_page=100&page=2>; rel="next", <https://api.github.com/user/30442/repos?per_page=100&page=2>; rel="last"' }
    )
  end

  it 'allows normal requests' do
    GH['users/rkh']['name'].should be == 'Konstantin Haase'
  end

  it 'sets in_parallel?' do
    GH.should_not be_in_parallel
    GH.in_parallel { GH.should be_in_parallel }
    GH.should_not be_in_parallel
  end

  it 'runs requests in parallel' do
    WebMock.allow_net_connect!
    GH::DefaultStack.replace GH::MockBackend, GH::Remote
    GH.current = nil
    GH.should_not be_in_parallel

    a = b = nil
    GH.in_parallel do
      GH.should be_in_parallel

      a = GH['users/rkh']
      b = GH['users/svenfuchs']

      expect { a['name'] }.to raise_error(RuntimeError)
      expect { b['name'] }.to raise_error(RuntimeError)
    end

    a['name'].should be == "Konstantin Haase"
    b['name'].should be == "Sven Fuchs"

    a.should respond_to('to_hash')
    b.should respond_to('to_hash')

    GH.should_not be_in_parallel
  end

  it 'runs requests right away if parallelize is set to false' do
    WebMock.allow_net_connect!
    GH::DefaultStack.replace GH::MockBackend, GH::Remote
    GH.with :parallelize => false do
      GH.should_not be_in_parallel

      a = b = nil
      GH.in_parallel do
        GH.should_not be_in_parallel

        a = GH['users/rkh']
        b = GH['users/svenfuchs']

        a['name'].should be == "Konstantin Haase"
        b['name'].should be == "Sven Fuchs"
      end

      a['name'].should be == "Konstantin Haase"
      b['name'].should be == "Sven Fuchs"

      GH.should_not be_in_parallel
    end
  end

  it 'works with pagination' do
    WebMock.allow_net_connect!
    GH::DefaultStack.replace GH::MockBackend, GH::Remote
    repos = GH.in_parallel { GH['users/rkh/repos'] }
    counter = repos.to_a.map { 1 }.reduce(:+)
    counter.should be > 120
  end

  it 'returns the block value' do
    GH.in_parallel { 42 }.should be == 42
  end

  it 'works two times in a row' do
    WebMock.allow_net_connect!
    GH::DefaultStack.replace GH::MockBackend, GH::Remote

    a = GH.in_parallel { GH['users/rkh'] }
    b = GH.in_parallel { GH['users/svenfuchs'] }

    a['name'].should be == "Konstantin Haase"
    b['name'].should be == "Sven Fuchs"
  end
end
