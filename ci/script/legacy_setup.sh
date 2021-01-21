#!/bin/bash
set -e
source script/functions.sh

bundle install --standalone --binstubs --without coverage documentation

if [ -x ./bin/rspec ]; then
  echo "RSpec bin detected"
else
  if [ -x ./exe/rspec ]; then
    cp ./exe/rspec ./bin/rspec
    echo "RSpec restored from exe"
  else
    echo "No RSpec bin available"
    exit 1
  fi
fi
