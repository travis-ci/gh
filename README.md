# GH - Layered GitHub API client

This is a highly flexible, layered, low-level GitHub client library, trying to get out of your way and let you get to the GitHub data as simple as possible. Unless you add layers, you will end up with Hashes and Arrays. The approach and API should be familiar from projects like Rack or Faraday.

Simple example:

``` ruby
require 'gh'
puts GH['users/rkh']['name']
```

This will by default use all the middleware that ships with GH, in the following order

* `GH::Remote` - sends HTTP requests to GitHub and parses the response
* `GH::Normalizer` - renames fields consistenly, adds hypermedia links if possible
* `GH::Cache` - caches the responses (will use Rails cache if in Rails, in-memory cache otherwise)
* `GH::LazyLoader` - will load missing fields when accessed (handy for dealing with incomplete data without sending to many requests)
* `GH::LinkFollower` - will add content of hypermedia links as fields (lazyly), allows you to traverse relations

## Main Entry Points

Every layer has two main entry points:

* `[key]` - loads data from GitHub
* `load(data)` - takes data and applies modifications (handy for dealing with service hook payloads)

These two methods are exposed by any instance of a layer and the `GH` constant.

## Using a Single Layer

You can initialize and use any layer on its own:

``` ruby
gh = GH::Remote.new
puts gh['users/rkh']['name']
```

Layers know which other layer they should usually wrap (`Remote` wraps no other layer, `LazyLoader` and `LinkFollower` wrap `Normalizer` by default, anything else wraps `Remote`), so you can initialize them right away:

``` ruby
gh = GH::LazyLoader.new
```

You can also pass the layer that should be wrapped as an argument:

``` ruby
gh = GH::LazyLoader.new(GH::LinkFollower.new)
```

## Creating Your Own Stack

For convinience a stack DSL is provided:

``` ruby
# Same as GH::Normalizer.new(GH::Cache.new)
gh = GH::Stack.build do
  use GH::Normalizer
  use GH::Cache
end

puts gh['users/rkh']['name']
```

You can also create reusable `Stack` instances:

``` ruby
stack = GH::Stack.new do
  use GH::Normalizer
  use GH::Cache
end

gh = stack.build username: 'rkh', password: 'abc123'
puts gh['user']['name']
```

One such instance (with the standard setup) can be accessed as `GH::DefaultStack`

## Scoping

With the main goal to separate authentication from other logic, the `gh` library supports scopting:

``` ruby
GH.with GH::LazyLoader.new do
  puts GH['users/rkh']['name']
end
```

That way, you could create a stack with, for instance, an [access token](http://developer.github.com/v3/oauth/):

``` ruby
authenticated = GH::DefaultStack token: 'e72e16c7e42f292c6912e7710c838347ae178b4a'

GH.with(authenticated) do
  # ...
end
```

Since this is rather common, you can pass options directly to `with`:

``` ruby
GH.with(username: 'rkh', password: 'abc123') do
  # ...
end
```

Scoping is thread-safe.

## Is this production ready?

I hope so, we use it in production for [Travis CI](http://travis-ci.org/). The work on this library has been funded by the [Travis Love Campaign](https://love.travis-ci.org/).

## History

* 2012-04-12: 0.2.3 - better normalization
* 2012-04-10: 0.2.2 - improved link following
* 2012-04-10: 0.2.1 - bug fix release
* 2012-04-10: 0.2.0 - added link following plus bug fixes (mainly encoding issues)
* 2012-04-06: 0.1.2 - bug fix release (issues with cache reloading)
* 2012-04-06: 0.1.1 - bug fix release (DSL fixes)
* 2012-04-04: 0.1.0 - many bug fixes plus lazy loading
* 2012-03-21: 0.0.1 - first public release
* 2012-03-05: project started