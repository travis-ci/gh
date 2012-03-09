require 'gh'
require 'time'

module GH
  # Public: A Wrapper class that deals with normalizing Github responses.
  class Normalizer < Wrapper
    # Public: Fetches resource from Github and normalizes the response.
    #
    # Returns normalized Response.
    def [](key)
      normalize super
    end

    private

    def set_link(hash, type, href)
      links = hash["_links"] ||= {}
      links[type] = {"href" => href}
    end

    def normalize_response(response)
      response      = response.dup
      response.data = normalize response.data
      response
    end

    def normalize_hash(hash)
      corrected = {}

      hash.each_pair do |key, value|
        key = normalize_key(key, value)
        next if normalize_url(corrected, key, value)
        next if normalize_time(corrected, key, value)
        corrected[key] = normalize(value)
      end

      normalize_user(corrected)
      corrected
    end

    def normalize_time(hash, key, value)
      hash['date'] = Time.at(value).xmlschema if key == 'timestamp'
    end

    def normalize_user(hash)
      hash['owner']  ||= hash.delete('user') if hash['created_at']   and hash['user']
      hash['author'] ||= hash.delete('user') if hash['committed_at'] and hash['user']

      hash['committer'] ||= hash['author']    if hash['author']
      hash['author']    ||= hash['committer'] if hash['committer']
    end

    def normalize_url(hash, key, value)
      case key
      when "blog"
        set_link(hash. key, value)
      when "url"
        type = Addressable::URI.parse(value).host == api_host.host ? "self" : "html"
        set_link(hash, type, value)
      when /^(.+)_url$/
        set_link(hash, $1, value)
      end
    end

    def normalize_key(key, value = nil)
      case key
      when 'gravatar_url'         then 'avatar_url'
      when 'org'                  then 'organization'
      when 'orgs'                 then 'organizations'
      when 'username'             then 'login'
      when 'repo'                 then 'repository'
      when 'repos'                then normalize_key('repositories', value)
      when /^repos?_(.*)$/        then "repository_#{$1}"
      when /^(.*)_repo$/          then "#{$1}_repository"
      when /^(.*)_repos$/         then "#{$1}_repositories"
      when 'commit', 'commit_id'  then value =~ /^\w{40}$/ ? 'sha' : key
      when 'comments'             then Numeric === value ? 'comment_count'    : key
      when 'forks'                then Numeric === value ? 'fork_count'       : key
      when 'repositories'         then Numeric === value ? 'repository_count' : key
      when /^(.*)s_count$/        then "#{$1}_count"
      else key
      end
    end

    def normalize_array(array)
      array.map { |e| normalize(e) }
    end

    def normalize(object)
      case object
      when Hash     then normalize_hash(object)
      when Array    then normalize_array(object)
      when Response then normalize_response(object)
      else object
      end
    end
  end
end
