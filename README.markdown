# Rspec 2 Development

This repository is for anyone interested in contributing to rspec-2 or
rspec-rails-2. To do so, you'll need a number of additional repositories and
dependent gems:

## Setting up the environment 

The rspec-2 dev environment uses bundler to install all the gems you need.
This works best if you're working in a development environment that does _not_
require you to use sudo to install gems. If you're not already using something
like rvm to manage your gem environments, do yourself a favor and start today.

    gem install rake bundler
    git clone git://github.com/rspec/rspec-dev.git
    cd rspec-dev
    rake setup
    rake spec 

If all goes well, you'll end up seeing a lot of passing cucumber features
and rspec code examples. You'll also have a directory structure that looks
like this:

    rspec-dev
      repos
        rspec-core         # rspec runner, describe, it, etc
        rspec-expectations # should, should_not + matchers
        rspec-mocks        # doubles, mocks, stubs, fakes, etc
        rspec-rails        # rspec 2 for rails 3
          tmp
            rails          # clone of the rails repo used for spec'ing rspec-rails
            example_app    # gets generated when running rspec-rails' specs 
        rspec              # meta-gem that depends on core, expectations, and mocks

After the initial clone you can run `rake git:pull` from the rspec-dev
directory to update all of the rspec repos (in repos).

Run `rake -T` to see the available tasks for dev mode.

# Contributing

Once you've set up the environment, you'll need to cd into the working
directory of whichever repo you want to work in. From there you can run the
specs and cucumber features, and make patches.

## Patches

Patches will not be accepted without being associated with an issue. Pull
requests are fine, but please include a link to the issue you are addressing.

## Issues

We're using github issues to track rspec-2 issues. Each repo has its own issue
tracker, so please use the appropriate one:

* [http://github.com/rspec/rspec-core/issues](http://github.com/rspec/rspec-core/issues)
* [http://github.com/rspec/rspec-dev/issues](http://github.com/rspec/rspec-dev/issues)
* [http://github.com/rspec/rspec-expectations/issues](http://github.com/rspec/rspec-expectations/issues)
* [http://github.com/rspec/rspec-mocks/issues](http://github.com/rspec/rspec-mocks/issues)
* [http://github.com/rspec/rspec-rails/issues](http://github.com/rspec/rspec-rails/issues)

# Troubleshooting the environment

## Load path and rubygems

Not everybody uses rubygems as their package management system. If this
sounds odd to you, read http://gist.github.com/54177.

In light of this fact, these repositories are "require 'rubygems'" free, so
you'll need to do any of the following:

    export RUBYOPT=rubygems
    set RUBYOPT=rubygems

For those of you who prefer not to add this to your primary environment, there
are plenty of solutions available to your managing multiple ruby environments.

## no such file to load -- spec_helper (LoadError)

Rspec adds ./lib and ./spec to the load path, so you have to run the `rspec`
command from the root of the repository you're working on. i.e. if you're
working on rspec-core, cd to the rspec-core directory. Don't try to run specs
from the rspec-dev directory, or you'll see `LoadError`s.

## different problem?

If you run into a problem not documented here, please check the rspec-dev
issues tracker to see if someone else has already reported it. If not, please
add one.

## solution to a problem not documented here?

If you solve a problem that is not documented here, please share the love
by submitting a patch to this README.

# Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)
* [http://github.com/rspec/rspec-rails](http://github.com/rspec/rspec-rails)

