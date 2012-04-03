require 'spec_helper'

describe GH::Normalizer do
  before { subject.backend = GH::MockBackend.new }

  def normalize(payload)
    data['/payload'] = payload
  end

  def with_headers(headers = {})
    response = GH::Response.new(headers)
    data['/payload'], response.data = response, data['/payload']
  end

  def normalized
    subject['/payload']
  end

  it 'is set up properly' do
    backend.frontend.should be_a(GH::Normalizer)
  end

  it 'leaves unknown fields in place' do
    normalize 'foo' => 'bar'
    normalized['foo'].should be == 'bar'
  end

  it 'works for deeply nested fields'
  it 'works for lists'

  context 'date fields' do
    it 'generates date from timestamp'
  end

  context 'renaming' do
    def self.renames(a, b)
      it "renames #{a} to #{b}" do
        normalize a => "foo"
        normalized.should_not include(a)
        normalized.should include(b)
        normalized[b].should be == "foo"
      end
    end

    renames 'org', 'organization'
    renames 'orgs', 'organizations'
    renames 'username', 'login'
    renames 'repo', 'repository'
    renames 'repos', 'repositories'
    renames 'repo_foo', 'repository_foo'
    renames 'repos_foo', 'repository_foo'
    renames 'foo_repo', 'foo_repository'
    renames 'foo_repos', 'foo_repositories'

    it 'renames commit to sha if value is a sha' do
      normalize 'commit' => 'd0f4aa01f100c26c6eae17ea637f46cf150d9c1f'
      normalized.should_not include('commit')
      normalized.should include('sha')
      normalized['sha'].should be == 'd0f4aa01f100c26c6eae17ea637f46cf150d9c1f'
    end

    it 'does not rename commit to sha if value is not a sha' do
      normalize 'commit' => 'foo'
      normalized.should include('commit')
      normalized.should_not include('sha')
      normalized['commit'].should be == 'foo'
    end

    it 'renames commit_id to sha if value is a sha' do
      normalize 'commit_id' => 'd0f4aa01f100c26c6eae17ea637f46cf150d9c1f'
      normalized.should_not include('commit_id')
      normalized.should include('sha')
      normalized['sha'].should be == 'd0f4aa01f100c26c6eae17ea637f46cf150d9c1f'
    end

    it 'does not rename commit_id to sha if value is not a sha' do
      normalize 'commit_id' => 'foo'
      normalized.should include('commit_id')
      normalized.should_not include('sha')
      normalized['commit_id'].should be == 'foo'
    end

    it 'renames comments to comment_count if content is a number' do
      normalize 'comments' => 42
      normalized.should include('comment_count')
      normalized.should_not include('comments')
      normalized['comment_count'].should be == 42
    end

    it 'renames repositories to repository_count if content is a number' do
      normalize 'repositories' => 42
      normalized.should include('repository_count')
      normalized.should_not include('repositories')
      normalized['repository_count'].should be == 42
    end

    it 'renames repos to repository_count if content is a number' do
      normalize 'repos' => 42
      normalized.should include('repository_count')
      normalized.should_not include('repos')
      normalized['repository_count'].should be == 42
    end

    it 'renames forks to fork_count if content is a number' do
      normalize 'forks' => 42
      normalized.should include('fork_count')
      normalized.should_not include('forks')
      normalized['fork_count'].should be == 42
    end

    it 'does not rename comments to comment_count if content is not a number' do
      normalize 'comments' => 'foo'
      normalized.should include('comments')
      normalized.should_not include('comment_count')
      normalized['comments'].should be == 'foo'
    end

    it 'does not rename repositories to repository_count if content is not a number' do
      normalize 'repositories' => 'foo'
      normalized.should include('repositories')
      normalized.should_not include('repository_count')
      normalized['repositories'].should be == 'foo'
    end

    it 'does not rename repos to repository_count if content is not a number' do
      normalize 'repos' => 'foo'
      normalized.should include('repositories')
      normalized.should_not include('repository_count')
      normalized['repositories'].should be == 'foo'
    end

    it 'does not rename forks to fork_count if content is not a number' do
      normalize 'forks' => 'foo'
      normalized.should include('forks')
      normalized.should_not include('fork_count')
      normalized['forks'].should be == 'foo'
    end

    it 'renames user to owner if appropriate' do
      normalize 'user' => 'me', 'created_at' => Time.now.xmlschema
      normalized.should_not include('user')
      normalized.should include('owner')
      normalized['owner'].should be == 'me'
    end

    it 'renames user to author if appropriate' do
      normalize 'user' => 'me', 'committed_at' => Time.now.xmlschema
      normalized.should_not include('user')
      normalized.should include('author')
      normalized['author'].should be == 'me'
    end

    it 'leaves user in place if owner exists' do
      normalize 'user' => 'me', 'created_at' => Time.now.xmlschema, 'owner' => 'you'
      normalized.should include('user')
      normalized.should include('owner')
      normalized['user'].should be == 'me'
      normalized['owner'].should be == 'you'
    end

    it 'leaves user in place if author exists' do
      normalize 'user' => 'me', 'committed_at' => Time.now.xmlschema, 'author' => 'you'
      normalized.should include('user')
      normalized.should include('author')
      normalized['user'].should be == 'me'
      normalized['author'].should be == 'you'
    end

    it 'leaves user in place if no indication what kind of user' do
      normalize 'user' => 'me'
      normalized.should_not include('owner')
      normalized.should_not include('author')
      normalized.should include('user')
      normalized['user'].should be == 'me'
    end

    it 'copies author to committer' do
      normalize 'author' => 'me'
      normalized.should include('author')
      normalized.should include('committer')
      normalized['author'].should be == 'me'
      normalized['author'].should be_equal(normalized['committer'])
    end

    it 'copies committer to author' do
      normalize 'committer' => 'me'
      normalized.should include('author')
      normalized.should include('committer')
      normalized['author'].should be == 'me'
      normalized['author'].should be_equal(normalized['committer'])
    end

    it 'does not override committer or author if both exist' do
      normalize 'committer' => 'me', 'author' => 'you'
      normalized.should include('author')
      normalized.should include('committer')
      normalized['author'].should be == 'you'
      normalized['committer'].should be == 'me'
    end
  end

  context 'links' do
    it 'generates link entries from link headers' do
      pending
      normalize '_links' => {'href' => 'foo'}
      with_headers

      normalized.headers.should include("Link")
      normalized.headers["Link"].should be == "something something"
    end

    it 'generates link headers from link entries'
    it 'does not discard existing link entires'
    it 'does not discard existing link headers'

    it 'identifies _url suffix as link' do
      normalize 'foo_url' => 'http://lmgtfy.com/?q=foo'
      normalized.should_not include('foo_url')
      normalized.should include("_links")
      normalized["_links"].should include("foo")
      normalized["_links"]["foo"].should be_a(Hash)
      normalized["_links"]["foo"]["href"].should be == 'http://lmgtfy.com/?q=foo'
    end

    it 'identifies blog as link' do
      normalize 'blog' => 'http://rkh.im'
      normalized.should_not include('blog')
      normalized.should include("_links")
      normalized["_links"].should include("blog")
      normalized["_links"]["blog"].should be_a(Hash)
      normalized["_links"]["blog"]["href"].should be == 'http://rkh.im'
    end

    it 'detects avatar links from gravatar_url' do
      normalize 'gravatar_url' => 'http://gravatar.com/avatar/93c02710978db9979064630900741691?size=50'
      normalized.should_not include('gravatar_url')
      normalized.should include("_links")
      normalized["_links"].should include("avatar")
      normalized["_links"]["avatar"].should be_a(Hash)
      normalized["_links"]["avatar"]["href"].should be == 'http://gravatar.com/avatar/93c02710978db9979064630900741691?size=50'
    end

    it 'detects html urls in url field' do
      normalize 'url' => 'http://github.com/foo'
      normalized.should_not include('url')
      normalized.should include('_links')
      normalized['_links'].should include('html')
      normalized['_links']['html']['href'].should be == 'http://github.com/foo'
    end

    it 'detects self urls in url field'  do
      normalize 'url' => 'http://api.github.com/foo'
      normalized.should_not include('url')
      normalized.should include('_links')
      normalized['_links'].should include('self')
      normalized['_links'].should_not include('html')
      normalized['_links']['self']['href'].should be == 'http://api.github.com/foo'
    end

    it 'passes through true' do
      normalize 'foo' => true
      normalized['foo'].should be == true
    end
  end
end
