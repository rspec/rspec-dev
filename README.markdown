# Rspec 2 Development

This repository is for anyone interested in contributing to rspec-2 or
rspec-rails-2.

## Setting up the environment 

### System pre-reqs:

    git
    sqlite3 # for rspec-rails

### Environment

The safest bet is to use rvm with an rvm installed ruby (not system ruby) and
a clean gemset dedicated to rspec-dev:

    rvm 1.9.2@rspec-dev --create # or whatever version of Ruby you prefer

Windows users can use pik instead of rvm.

If you use a different Ruby version manager (or none at all), the important
thing is that you have a sandboxed gem environment that does not require you to
use sudo to install gems, and has no rspec libraries installed.

### required gems

You just need to install bundler to start:

    gem install bundler

Bundler will only install if you have RubyGems 1.3.6 or later, so you may need
to update RubyGems first:

    gem update --system

### Once bundler installed

Once you have all the pre-reqs listed above, here's all you need to do
to set up your environment:

    git clone git://github.com/rspec/rspec-dev.git
    cd rspec-dev
    bundle install --binstubs
    bin/rake setup
    bin/rake

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

## Documentation

It's not currently [possible][doc-regen] for you to regenerate the [HTML
documentation](http://relishapp.com/rspec) from the cukes (in the `features`
directories).  It's still easy to edit them though: Just make sure that the
narrative is valid (indented) Markdown.

[doc-regen]: http://rubyforge.org/pipermail/rspec-devel/2011-January/005350.html

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
sounds odd to you, read http://gist.github.com/54177.

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
