require 'gh'

module GH
  # Public: ...
  class LazyLoader < Wrapper
    wraps GH::Normalizer
    double_dispatch

    def modify_hash(hash, loaded = false)
      hash = super(hash)
      link = hash['_links'].try(:[], 'self') unless loaded
      setup_lazy_loading(hash, link['href']) if link
      hash
    end

    private

    def lazy_load(hash, key, link)
      result = modify_hash(backend[link].data, true)
    end
  end
end
