#!/bin/bash

set -e

RUBY_VERSION=`ruby -v`

if [ "${RUBY_VERSION}" = *1.8.7* ]
then
  echo 'Updating RubyGems to 2.1.11'
  gem update --system 2.1.11
fi

BUNDLER_VERSION=`bundle -v`

if [ "${BUNDLER_VERSION}" = *1.5.0 ]
then
  puts 'Updating Bundler to 1.5.1'
  gem install bundler -v '= 1.5.1'
fi
