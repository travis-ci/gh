require 'spec_helper'

describe GH::Normalizer do
  before { subject.backend = GH::MockBackend.new }

  def normalize(payload)
    data['payload'] = payload
  end

  def normalized
    subject['payload']
  end

  it 'leaves unknown fields in place' do
    normalize 'foo' => 'bar'
    normalized['foo'] = 'bar'
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

    it 'renames comments to comment_count if content is a number'
    it 'renames repositories to repository_count if content is a number'
    it 'renames repos to repository_count if content is a number'
    it 'renames forks to fork_count if content is a number'
    it 'renames user to owner if appropriate'
    it 'renames user to author if appropriate'
    it 'leaves user in place if owner exists'
    it 'leaves user in place if author exists'
    it 'leaves user in place if no indication what kind of user'
    it 'copies author to committer'
    it 'copies committer to author'
    it 'does not override committer or author if both exist'
  end

  context 'links' do
    it 'generates link entries from link headers'
    it 'generates link headers from link entries'
    it 'does not discard existing link entires'
    it 'does not discard existing link headers'
    it 'identifies _url prefix as link'
    it 'identifies blog as link'
    it 'detects avatar links from gravatar_url'
    it 'detects html urls in url field'
    it 'detects self urls in url field'
  end
end
