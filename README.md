**This is work in progress and not yet usable!**

Goal of this library is to ease usage of the Github API as part of large, tightly integrated, distributed projects, such as [Travis CI](http://travis-ci.org). It was born out due to issues we ran into with all existing Github libraries and the Github API itself.

With that in mind, this library follows the following goals:

* Implement features in separate layers, make layers as independend of each other as possible
* Higher level layers should not worry about when to send requests
* It should only send requests to Github when necessary
* It should be able to fetch data from Github asynchronously (i.e. HTTP requests to Travis should not be bound to HTTP requests to Github, if possible)
* It should be able to deal with events and hooks well (i.e. update cached entities with hook data)
* It should not have intransparent magic (i.e. implicit, undocumented requirements on fields we get from Github)
* It should shield against possible changes to the Github API or at least complain about those changes if it can't deal with it.

Most of this is not yet implemented!

The lower level APIs support a Rack-like stacking API:

``` ruby
api = GH::Stack.build do
  use GH::Cache, cache: Rails.cache
  use GH::Normalizer
  use GH::Remote, username: "admin", password: "admin"
end
```

Usage example:

``` ruby
GH.with username: 'rkh' password: 'abc123' do
  sven = GH['users/svenfuchs']

  if sven['hireable']
    # recruiter has to be provided by some different library
    Recruiter.contact sven['email']
  end
end
```
