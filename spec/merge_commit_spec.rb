require 'spec_helper'

describe GH::MergeCommit do
  let(:file) { File.expand_path('../pull_request_hook.json', __FILE__) }
  let(:payload) { File.read file }
  let(:gh) { GH.load payload }
  let(:pull_request) { gh['pull_request'] }

  before do
    stub_request(:get, "https://github.com/travis-repos/test-project-1/pull/1/mergeable").
      to_return(:status => 200, :body => "true", :headers => {})
  end

  it 'adds merge commits' do
    pull_request['merge_commit']['sha'].should_not be_nil
  end

  it 'adds base commits' do
    pull_request['base_commit']['sha'].should_not be_nil
  end

  it 'adds head commits' do
    pull_request['head_commit']['sha'].should_not be_nil
  end

  it 'allows lazy loading on the commit' do
    pull_request['merge_commit']['committer']['name'] == 'GitHub Merge Button'
  end
end
