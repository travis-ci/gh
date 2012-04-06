require 'gh'

module GH
  # Public: ...
  class LazyLoader < Wrapper
    wraps GH::Normalizer
    double_dispatch

    def modify_hash(hash)
      hash = super
      link = hash['_links'].try(:[], 'self')
      setup_lazy_loading(hash, link['href']) if link
      hash
    end

    private

    def lazy_load(hash, key, link)
      backend[link]
    end
  end
end
