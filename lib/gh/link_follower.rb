module GH
  class LinkFollower < Wrapper
    wraps GH::Normalizer
    double_dispatch

    def modify_hash(hash)
      hash = super(hash)
      setup_lazy_loading(hash) if hash['_links']
      hash
    rescue => e
      raise Error.new(e, hash)
    end

    private

    def lazy_load(hash, key)
      link = hash['_links'][key]
      { key => self[link['href']] } if link
    rescue => e
      raise Error.new(e, hash)
    end
  end
end
