# frozen_string_literal: true

require 'spec_helper'

describe GH::MergeCommit do
  let(:payload) { load_response_stub('pull_request_hook') }
  let(:gh) { GH.load payload }
  let(:pull_request) { gh['pull_request'] }

  it 'adds merge commits' do
    expect(pull_request['merge_commit']['sha']).not_to be_nil
  end

  it 'adds base commits' do
    expect(pull_request['base_commit']['sha']).not_to be_nil
  end

  it 'adds head commits' do
    expect(pull_request['head_commit']['sha']).not_to be_nil
  end

  it 'allows lazy loading on the commit' do
    expect(pull_request['merge_commit']['committer']['name']).to eql('GitHub Merge Button')
  end

  context 'when pull request is draft' do
    let(:payload) { load_response_stub('draft_pull_request_hook') }

    it 'adds merge commits' do
      expect(pull_request['merge_commit']['sha']).not_to be_nil
    end
  end
end
