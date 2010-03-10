# Rspec 2 Development Environment Setup

    git clone git://github.com/rspec/rspec-dev.git
    cd rspec-dev
    gem install bundler
    bundle install
    rake git:clone
    rake gem:install
    rake

After the initial clone you can run `rake git:pull` to update to the latest bits.

Run `rake -T` to see the available tasks for dev mode.

# Troubleshooting

These repositories are "require 'rubygems'" free, so you'll need to do any
of the following:

    export RUBYOPT=rubygems
    set RUBYOPT=rubygems

# Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)

