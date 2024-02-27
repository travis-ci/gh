# frozen_string_literal: true

require 'gh'

module GH
  # Public: ...
  class LazyLoader < Wrapper
    wraps GH::Normalizer
    double_dispatch

    def modify_hash(hash, loaded = false) # rubocop:disable Style/OptionalBooleanParameter
      hash = super(hash)
      link = hash['_links']['self'] unless loaded || hash['_links'].nil?
      setup_lazy_loading(hash, link['href']) if link
      hash
    rescue StandardError => e
      raise Error.new(e, hash)
    end

    private

    def lazy_load(hash, _key, link)
      modify_hash(backend[link].data, true)
    rescue StandardError => e
      raise Error.new(e, hash)
    end
  end
end
