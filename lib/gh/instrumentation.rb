# frozen_string_literal: true

require 'gh'

module GH
  # Public: This class caches responses.
  class Instrumentation < Wrapper
    # Public: Get/set instrumenter to use. Compatible with ActiveSupport::Notification and Travis::EventLogger.
    attr_accessor :instrumenter

    def setup(backend, options)
      self.instrumenter ||= Travis::EventLogger.method(:notify) if defined? Travis::EventLogger
      self.instrumenter ||= ActiveSupport::Notifications.method(:instrument) if defined? ActiveSupport::Notifications
      super
    end

    def http(verb, url, *)
      instrument(:http, verb:, url:) { super }
    end

    def load(data)
      instrument(:load, data:) { super }
    end

    def [](key)
      instrument(:access, key:) { super }
    end

    private

    def instrument(type, payload = {})
      return yield unless instrumenter

      result = nil
      instrumenter.call("#{type}.gh", payload.merge(gh: frontend)) { result = yield }
      result
    end
  end
end
