require 'spec_helper'

describe GH::Normalizer do
  subject(:normalizer) { described_class.new }

  before { normalizer.backend = GH::MockBackend.new }

  def normalize(payload)
    data[normalizer.path_for('/payload')] = payload
  end

  def with_headers(headers = {})
    response = GH::Response.new('{}', headers)
    response.data = data[normalizer.path_for('/payload')]
    data[normalizer.path_for('/payload')] = response
  end

  def normalized
    normalizer[normalizer.path_for('/payload')]
  end

  it 'is set up properly' do
    expect(backend.frontend).to be_a(described_class)
  end

  it 'leaves unknown fields in place' do
    normalize 'foo' => 'bar'
    expect(normalized['foo']).to eql('bar')
  end

  it 'allows normalization with #load' do
    result = normalizer.load('org' => 'foo')
    expect(result).not_to include('org')
    expect(result['organization']).to eql('foo')
  end

  it 'works for deeply nested fields'
  it 'works for lists'

  context 'when testing date fields' do
    it 'generates date from timestamp'
  end

  context 'when renaming' do
    def self.renames(a, b)
      it "renames #{a} to #{b}" do
        normalize a => 'foo'
        expect(normalized).not_to include(a)
        expect(normalized).to include(b)
        expect(normalized[b]).to eql('foo')
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
      expect(normalized).not_to include('commit')
      expect(normalized).to include('sha')
      expect(normalized['sha']).to eql('d0f4aa01f100c26c6eae17ea637f46cf150d9c1f')
    end

    it 'does not rename commit to sha if value is not a sha' do
      normalize 'commit' => 'foo'
      expect(normalized).to include('commit')
      expect(normalized).not_to include('sha')
      expect(normalized['commit']).to eql('foo')
    end

    it 'renames commit_id to sha if value is a sha' do
      normalize 'commit_id' => 'd0f4aa01f100c26c6eae17ea637f46cf150d9c1f'
      expect(normalized).not_to include('commit_id')
      expect(normalized).to include('sha')
      expect(normalized['sha']).to eql('d0f4aa01f100c26c6eae17ea637f46cf150d9c1f')
    end

    it 'does not rename commit_id to sha if value is not a sha' do
      normalize 'commit_id' => 'foo'
      expect(normalized).to include('commit_id')
      expect(normalized).not_to include('sha')
      expect(normalized['commit_id']).to eql('foo')
    end

    it 'renames comments to comment_count if content is a number' do
      normalize 'comments' => 42
      expect(normalized).to include('comment_count')
      expect(normalized).not_to include('comments')
      expect(normalized['comment_count']).to be(42)
    end

    it 'renames repositories to repository_count if content is a number' do
      normalize 'repositories' => 42
      expect(normalized).to include('repository_count')
      expect(normalized).not_to include('repositories')
      expect(normalized['repository_count']).to be(42)
    end

    it 'renames repos to repository_count if content is a number' do
      normalize 'repos' => 42
      expect(normalized).to include('repository_count')
      expect(normalized).not_to include('repos')
      expect(normalized['repository_count']).to be(42)
    end

    it 'renames forks to fork_count if content is a number' do
      normalize 'forks' => 42
      expect(normalized).to include('fork_count')
      expect(normalized).not_to include('forks')
      expect(normalized['fork_count']).to be(42)
    end

    it 'does not rename comments to comment_count if content is not a number' do
      normalize 'comments' => 'foo'
      expect(normalized).to include('comments')
      expect(normalized).not_to include('comment_count')
      expect(normalized['comments']).to eql('foo')
    end

    it 'does not rename repositories to repository_count if content is not a number' do
      normalize 'repositories' => 'foo'
      expect(normalized).to include('repositories')
      expect(normalized).not_to include('repository_count')
      expect(normalized['repositories']).to eql('foo')
    end

    it 'does not rename repos to repository_count if content is not a number' do
      normalize 'repos' => 'foo'
      expect(normalized).to include('repositories')
      expect(normalized).not_to include('repository_count')
      expect(normalized['repositories']).to eql('foo')
    end

    it 'does not rename forks to fork_count if content is not a number' do
      normalize 'forks' => 'foo'
      expect(normalized).to include('forks')
      expect(normalized).not_to include('fork_count')
      expect(normalized['forks']).to eql('foo')
    end

    it 'renames user to owner if appropriate' do
      normalize 'user' => 'me', 'created_at' => Time.now.xmlschema
      expect(normalized).not_to include('user')
      expect(normalized).to include('owner')
      expect(normalized['owner']).to eql('me')
    end

    it 'renames user to author if appropriate' do
      normalize 'user' => 'me', 'committed_at' => Time.now.xmlschema
      expect(normalized).not_to include('user')
      expect(normalized).to include('author')
      expect(normalized['author']).to eql('me')
    end

    it 'leaves user in place if owner exists' do
      normalize 'user' => 'me', 'created_at' => Time.now.xmlschema, 'owner' => 'you'
      expect(normalized).to include('user')
      expect(normalized).to include('owner')
      expect(normalized['user']).to eql('me')
      expect(normalized['owner']).to eql('you')
    end

    it 'leaves user in place if author exists' do
      normalize 'user' => 'me', 'committed_at' => Time.now.xmlschema, 'author' => 'you'
      expect(normalized).to include('user')
      expect(normalized).to include('author')
      expect(normalized['user']).to eql('me')
      expect(normalized['author']).to eql('you')
    end

    it 'leaves user in place if no indication what kind of user' do
      normalize 'user' => 'me'
      expect(normalized).not_to include('owner')
      expect(normalized).not_to include('author')
      expect(normalized).to include('user')
      expect(normalized['user']).to eql('me')
    end

    it 'copies author to committer' do
      normalize 'author' => 'me'
      expect(normalized).to include('author')
      expect(normalized).to include('committer')
      expect(normalized['author']).to eql('me')
    end

    it 'copies committer to author' do
      normalize 'committer' => 'me'
      expect(normalized).to include('author')
      expect(normalized).to include('committer')
      expect(normalized['author']).to eql('me')
    end

    it 'does not override committer or author if both exist' do
      normalize 'committer' => 'me', 'author' => 'you'
      expect(normalized).to include('author')
      expect(normalized).to include('committer')
      expect(normalized['author']).to eql('you')
      expect(normalized['committer']).to eql('me')
    end
  end

  context 'when testing time' do
    it 'transforms timestamps stored in "timestamp" to a date in "date"' do
      normalize 'timestamp' => 1234
      expect(normalized['date']).to eql('1970-01-01T00:20:34Z')
    end

    it 'transforms dates stored in "timestamp" to a date in "date"' do
      normalize 'timestamp' => '2012-04-12T17:29:51+02:00'
      expect(normalized['date']).to eql('2012-04-12T15:29:51Z')
    end

    it 'changes date to UTC' do
      normalize 'date' => '2012-04-12T17:29:51+02:00'
      expect(normalized['date']).to eql('2012-04-12T15:29:51Z')
    end

    it 'changes any time entry to UTC' do
      normalize 'foo' => '2012-04-12T17:29:51+02:00'
      expect(normalized['foo']).to eql('2012-04-12T15:29:51Z')
    end

    it 'does not choke on empty values' do
      normalize 'date' => ''
      expect(normalized['date']).to eql('')
    end
  end

  context 'when testing links' do
    it 'does not normalize config' do
      normalize 'config' => { 'url' => 'http://localhost' }
      expect(normalized['config']).to eql('url' => 'http://localhost')
    end

    it 'generates link entries from link headers' do
      skip ''
      normalize '_links' => { 'href' => 'foo' }
      with_headers

      expect(normalized.headers).to include('Link')
      expect(normalized.headers['Link']).to eql('something something')
    end

    it 'generates link headers from link entries'
    it 'does not discard existing link entires'
    it 'does not discard existing link headers'

    it 'identifies _url suffix as link' do
      normalize 'foo_url' => 'http://lmgtfy.com/?q=foo'
      expect(normalized).not_to include('foo_url')
      expect(normalized).to include('_links')
      expect(normalized['_links']).to include('foo')
      expect(normalized['_links']['foo']).to be_a(Hash)
      expect(normalized['_links']['foo']['href']).to eql('http://lmgtfy.com/?q=foo')
    end

    it 'identifies blog as link' do
      normalize 'blog' => 'http://rkh.im'
      expect(normalized).not_to include('blog')
      expect(normalized).to include('_links')
      expect(normalized['_links']).to include('blog')
      expect(normalized['_links']['blog']).to be_a(Hash)
      expect(normalized['_links']['blog']['href']).to eql('http://rkh.im')
    end

    it 'detects avatar links from gravatar_url' do
      normalize 'gravatar_url' => 'http://gravatar.com/avatar/93c02710978db9979064630900741691?size=50'
      expect(normalized).not_to include('gravatar_url')
      expect(normalized).to include('_links')
      expect(normalized['_links']).to include('avatar')
      expect(normalized['_links']['avatar']).to be_a(Hash)
      expect(normalized['_links']['avatar']['href']).to eql('http://gravatar.com/avatar/93c02710978db9979064630900741691?size=50')
    end

    it 'detects html urls in url field' do
      normalize 'url' => 'http://github.com/foo'
      expect(normalized).not_to include('url')
      expect(normalized).to include('_links')
      expect(normalized['_links']).to include('html')
      expect(normalized['_links']['html']['href']).to eql('http://github.com/foo')
    end

    it 'detects self urls in url field' do
      normalize 'url' => 'https://api.github.com/foo'
      expect(normalized).not_to include('url')
      expect(normalized).to include('_links')
      expect(normalized['_links']).to include('self')
      expect(normalized['_links']).not_to include('html')
      expect(normalized['_links']['self']['href']).to eql('https://api.github.com/foo')
    end

    it 'passes through true' do
      normalize 'foo' => true
      expect(normalized['foo']).to be(true)
    end

    it 'properly detects html links when api is served from same host' do
      normalizer.backend.setup('http://localhost/api/v3', {})
      normalize 'url' => 'http://localhost/foo'
      expect(normalized).not_to include('url')
      expect(normalized).to include('_links')
      expect(normalized['_links']).to include('html')
      expect(normalized['_links']['html']['href']).to eql('http://localhost/foo')
    end

    it 'properly detects self links when api is served from same host' do
      normalizer.backend.setup('http://localhost/api/v3', {})
      normalize 'url' => 'http://localhost/api/v3/foo'
      expect(normalized).not_to include('url')
      expect(normalized).to include('_links')
      expect(normalized['_links']).to include('self')
      expect(normalized['_links']['self']['href']).to eql('http://localhost/api/v3/foo')
    end
  end
end
