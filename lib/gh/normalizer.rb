# frozen_string_literal: true

require 'gh'
require 'time'

module GH
  # Public: A Wrapper class that deals with normalizing Github responses.
  class Normalizer < Wrapper
    def generate_response(key, response)
      result = super
      links(result)['self'] ||= { 'href' => frontend.full_url(key).to_s } if result.respond_to? :to_hash
      result
    end

    private

    double_dispatch

    def links(hash)
      hash = hash.data if hash.respond_to? :data
      hash['_links'] ||= {}
    end

    def set_link(hash, type, href)
      links(hash)[type] = { 'href' => href }
    end

    def modify_response(response)
      response = response.dup
      response.data = modify response.data
      response
    end

    def modify_hash(hash)
      corrected = {}
      corrected.default_proc = hash.default_proc if hash.default_proc

      hash.each_pair do |key, value|
        key = modify_key(key, value)
        next if modify_url(corrected, key, value)
        next if modify_time(corrected, key, value)

        corrected[key] = modify(value)
      end

      modify_user(corrected)
      corrected
    end

    TIME_KEYS = %w[date timestamp committed_at created_at merged_at closed_at datetime time].freeze
    TIME_PATTERN = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\S*$/

    def modify_time(hash, key, value)
      return unless TIME_KEYS.include?(key) || (TIME_PATTERN === value)

      should_be = key == 'timestamp' ? 'date' : key
      raise ArgumentError if (RUBY_VERSION < '1.9') && (value == '') # TODO: remove this line. duh.

      time = begin
        Time.at(value)
      rescue StandardError
        Time.parse(value.to_s)
      end
      hash[should_be] = time.utc.xmlschema if time
    rescue ArgumentError, TypeError
      hash[should_be] = value
    end

    def modify_user(hash)
      hash['owner'] ||= hash.delete('user') if hash['created_at'] && hash['user']
      hash['author'] ||= hash.delete('user') if hash['committed_at'] && hash['user']

      hash['committer'] ||= hash['author'] if hash['author']
      hash['author'] ||= hash['committer'] if hash['committer']

      modify_user_fields hash['owner']
      modify_user_fields hash['user']
    end

    def modify_user_fields(hash)
      return unless hash.is_a?(Hash)

      hash['login'] = hash.delete('name') if hash['name']
      set_link hash, 'self', "users/#{hash['login']}" unless links(hash).include? 'self'
    end

    def modify_url(hash, key, value)
      case key
      when 'blog'
        set_link(hash, key, value)
      when 'url'
        type = value.to_s.start_with?(api_host.to_s) ? 'self' : 'html'
        set_link(hash, type, value)
      when /^(.+)_url$/
        set_link(hash, ::Regexp.last_match(1), value)
      when 'config'
        hash[key] = value
      end
    end

    def modify_key(key, value = nil)
      case key
      when 'gravatar_url' then 'avatar_url'
      when 'org' then 'organization'
      when 'orgs' then 'organizations'
      when 'username' then 'login'
      when 'repo' then 'repository'
      when 'repos' then modify_key('repositories', value)
      when /^repos?_(.*)$/ then "repository_#{::Regexp.last_match(1)}"
      when /^(.*)_repo$/ then "#{::Regexp.last_match(1)}_repository"
      when /^(.*)_repos$/ then "#{::Regexp.last_match(1)}_repositories"
      when 'commit', 'commit_id', 'id' then value.to_s =~ /^\w{40}$/ ? 'sha' : key
      when 'comments' then value.is_a?(Numeric) ? 'comment_count' : key
      when 'forks' then value.is_a?(Numeric) ? 'fork_count' : key
      when 'repositories' then value.is_a?(Numeric) ? 'repository_count' : key
      when /^(.*)s_count$/ then "#{::Regexp.last_match(1)}_count"
      else key
      end
    end
  end
end
