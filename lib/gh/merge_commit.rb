require 'gh'

module GH
  # Public: ...
  class MergeCommit < Wrapper
    wraps GH::Normalizer
    double_dispatch

    def setup(backend, options)
      @ssl = options[:ssl]
      super
    end

    def modify_hash(hash)
      setup_lazy_loading(super)
    end

    private

    def lazy_load(hash, key)
      return unless key =~ /^(merge|head|base)_commit$/ and hash.include? 'mergeable'
      return unless force_merge_commit(hash)
      fields = pull_request_refs(hash)
      fields['base_commit'] ||= commit_for hash, hash['base']
      fields['head_commit'] ||= commit_for hash, hash['head']
      fields
    end

    def commit_for(from, hash)
      { 'sha' => hash['sha'], 'ref' => hash['ref'],
        '_links' => { 'self' => { 'href' => git_url_for(from, hash['sha']) } } }
    end

    def git_url_for(hash, commitish)
      hash['_links']['self']['href'].gsub(%r{/pulls/(\d+)$}, "/git/#{commitish}")
    end

    def pull_request_refs(hash)
      link     = git_url_for(hash, 'refs/pull/\1')
      commits  = self[link].map do |data|
        ref    = data['ref']
        name   = ref.split('/').last + "_commit"
        object = data['object'].merge 'ref' => ref
        [name, object]
      end
      Hash[commits]
    end

    def force_merge_commit(hash)
      # FIXME: Rick said "this will become part of the API"
      # until then, please look the other way
      while hash['mergable'].nil?
        url = hash['_links']['html']['href'] + '/mergeable'
        case http(:get, url).body
        when "true"  then hash['mergable'] = true
        when "false" then hash['mergable'] = false
        end
      end
      hash['mergable']
    end
  end
end
