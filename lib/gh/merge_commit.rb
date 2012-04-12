require 'gh'

module GH
  # Public: ...
  class MergeCommit < Wrapper
    wraps GH::Normalizer
    double_dispatch

    def modify_hash(hash)
      hash = super
      setup_lazy_loading(hash) if hash.include? 'mergeable' and hash['mergeable']
      hash
    end

    private

    def lazy_load(hash, key)
      return unless key == 'merge_commit'
      link = hash['_links']['self']['href'].gsub(%r{/pulls/(\d+)$}, '/git/refs/pull/\1/merge')
      { key => backend[link] }
    end
  end
end
