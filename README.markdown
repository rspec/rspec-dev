# RSpec Development

This repository is for anyone interested in contributing to rspec or
rspec-rails.

## Environment

### System

    git
    sqlite3 # for rspec-rails

### Ruby

The safest bet is to use [rvm](https://github.com/wayneeseguin/rvm) with an rvm
installed ruby (not system ruby) and a clean gemset dedicated to rspec-dev:

    rvm 2.6@rspec-dev --create # or whatever version of Ruby you prefer

[rbenv](https://github.com/sstephenson/rbenv) is also supported.

Windows users can use [uru](https://bitbucket.org/jonforums/uru).

If you use a different Ruby version manager (or none at all), the important
thing is that you have a sandboxed gem environment that does not require you to
use sudo to install gems, and has no rspec libraries installed.

### Bundler

Bundler is required for dependency management. Install it first:

    gem install bundler

### rspec-dev

Once all of the pre-reqs above are taken care of, run these steps to get
bootstrapped:

    git clone git://github.com/rspec/rspec-dev.git
    cd rspec-dev
    bundle install --binstubs
    bin/rake setup
    bin/rake # runs tests in every repository

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
            aruba          # gets generated when running rspec-rails' cukes
            example_app    # gets generated when running rspec-rails' specs 
        rspec              # meta-gem that depends on core, expectations, and mocks

After the initial clone you can run `rake git:pull` from the rspec-dev
directory to update all of the rspec repos (in repos).

Run `rake -T` to see the available tasks for dev mode.

# Contributing

Once you've set up the environment, you'll need to cd into the working
directory of whichever repo you want to work in. From there you can run the
specs and cucumber features, and make patches.

NOTE: You do not need to use rspec-dev to work on a specific RSpec repo. You
can treat each RSpec repo as an independent project.

## Patches

Please submit a pull request or a github issue to one of the issue trackers
listed below. If you submit an issue, please include a link to either of:

* a gist (or equivalent) of the patch
* a branch or commit in your github fork of the repo

## Issues

* [https://github.com/rspec/rspec-core/issues](https://github.com/rspec/rspec-core/issues)
* [https://github.com/rspec/rspec-dev/issues](https://github.com/rspec/rspec-dev/issues)
* [https://github.com/rspec/rspec-expectations/issues](https://github.com/rspec/rspec-expectations/issues)
* [https://github.com/rspec/rspec-mocks/issues](https://github.com/rspec/rspec-mocks/issues)
* [https://github.com/rspec/rspec-rails/issues](https://github.com/rspec/rspec-rails/issues)

# Troubleshooting the environment

## Load path and rubygems

Not everybody uses rubygems as their package management system. If this
sounds odd to you, read https://gist.github.com/rtomayko/54177.

In light of this fact, these repositories are "require 'rubygems'" free. The
included Rakefiles use Bundler, which effectively manages all of this for
you.

If you're using any of these repos in isolation and without Bundler, however,
you may need to do one of the following:

    export RUBYOPT=rubygems
    set RUBYOPT=rubygems

For those of you who prefer not to add this to your primary environment, there
are plenty of solutions available to your managing multiple ruby environments.

## no such file to load -- spec_helper (LoadError)

Rspec adds ./lib and ./spec to the load path, so you have to run the `rspec`
command from the root of the repository you're working on. i.e. if you're
working on rspec-core, cd to the rspec-core directory. Don't try to run specs
from the rspec-dev directory, or you'll see `LoadError`s.

## Errors in Windows setup

If you get a `SSL error` in Windows, you can follow the instructions on this [link](https://gist.github.com/luislavena/f064211759ee0f806c88) to fix it.  

If you get this error `Gem::InstallError: The redcarpet native gem requires installed build tools`, download the development kit from [https://rubyinstaller.org/downloads](https://rubyinstaller.org/downloads). You can follow the installation instructions [here](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit).

## Different problem?

If you run into a problem not documented here, please check the rspec-dev
issues tracker to see if someone else has already reported it. If not, please
add one.

## Solution to a problem not documented here?

If you solve a problem that is not documented here, please share the love
by submitting a patch to this README.

# Also see

* [https://github.com/rspec/rspec](https://github.com/rspec/rspec)
* [https://github.com/rspec/rspec-core](https://github.com/rspec/rspec-core)
* [https://github.com/rspec/rspec-expectations](https://github.com/rspec/rspec-expectations)
* [https://github.com/rspec/rspec-mocks](https://github.com/rspec/rspec-mocks)
* [https://github.com/rspec/rspec-rails](https://github.com/rspec/rspec-rails)

## Other gems
These gems were extracted from past versions of RSpec in order to maintain 
compatibility for older spec suites upgrading to new versions, in particular
`rspec-its` adds back the `its(:thing)` style of spec, `rspec-collection_matchers` 
adds back `have(n).items` style matchers, `rspec-legacy_formatters` enables old
formatters to operate with RSpec 3+. These gems are in general not officially
maintained by the RSpec team but may receive support and maintenance as needs require.

* [https://github.com/rspec/rspec-activemodel-mocks](https://github.com/rspec/rspec-activemodel-mocks)
* [https://github.com/rspec/rspec-collection_matchers](https://github.com/rspec/rspec-collection_matchers)
* [https://github.com/rspec/rspec-its](https://github.com/rspec/rspec-its)
* [https://github.com/rspec/rspec-legacy_formatters](https://github.com/rspec/rspec-legacy_formatters)
