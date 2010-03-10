# Rspec 2 Development


## Setting up the environment 

The rspec-2 dev environment uses bundler to install all the gems you need.
This works best if you're working in a development environment that does
_not_ require you to use sudo to install gems.

    gem install bundler
    git clone git://github.com/rspec/rspec-dev.git
    cd rspec-dev
    rake setup
    rake spec 

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

