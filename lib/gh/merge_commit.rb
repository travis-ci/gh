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
      return unless key =~ /^(merge|head)_commit$/ and hash.include? 'mergeable'

      # FIXME: Rick said "this will become part of the API"
      # until then, please look the other way
      while hash['mergable'].nil?
        url = hash['_links']['html']['href'] + '/mergeable'
        case http(url).body
        when "true"  then hash['mergable'] = true
        when "false" then hash['mergable'] = false
        end
      end

      link     = hash['_links']['self']['href'].gsub(%r{/pulls/(\d+)$}, '/git/refs/pull/\1')
      commits  = self[link].map do |data|
        ref    = data['ref']
        name   = ref.split('/').last + "_commit"
        object = data['object'].merge 'ref' => ref
        [name, object]
      end
      Hash[commits]
    end
  end
end
