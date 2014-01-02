#!/bin/bash

set -e

RUBY_VERSION=`ruby -v`

if echo ${RUBY_VERSION} | grep '1\.8\.7' 2>&1 > /dev/null
then
  echo 'Updating RubyGems to 2.1.11'
  gem update --system 2.1.11
fi

BUNDLER_VERSION=`bundle -v`

if echo ${BUNDLER_VERSION} | grep '1\.5\.0' 2>&1 > dev/null
then
  echo 'Updating Bundler to 1.5.1'
  gem install bundler -v '= 1.5.1'
fi
