require 'gh'

module GH
  # Public: ...
  class LazyLoader < Wrapper
    wraps GH::Normalizer
    double_dispatch

    def modify_hash(hash, loaded = false)
      hash = super(hash)
      link = hash['_links']['self'] unless loaded || hash['_links'].nil?
      setup_lazy_loading(hash, link['href']) if link
      hash
    rescue => e
      raise Error.new(e, hash)
    end

    private

    def lazy_load(hash, _key, link)
      modify_hash(backend[link].data, true)
    rescue => e
      raise Error.new(e, hash)
    end
  end
end
