require 'gh'

module GH
  # Public: In some cases, the GitHub API can take some number of
  # seconds to reflect a change in the system. This class catches 404
  # responses for any GET request and retries the request.
  class Retry < Wrapper
    DEFAULTS = {
      retries: 5,
      wait: 1
    }

    attr_accessor :retries, :wait

    def initialize(backend = nil, options = {})
      options = DEFAULTS.merge options
      super backend, options
    end

    def fetch_resource(key)
      begin
        decrement_retries!
        super key
      rescue GH::Error(response_status: 404) => e
        retries_remaining? or raise e
        sleep wait
        fetch_resource key
      end
    end

    private

    def decrement_retries!
      self.retries = self.retries - 1
    end

    def retries_remaining?
      retries > 0
    end
  end
end
