# Rspec 2 Development Environment Setup


    git clone git://github.com/rspec/rspec-dev.git
    cd rspec-dev
    gem install bundler
    bundle install
    rake git:clone
    rake gem:install
    rake

To setup your development environment run `rake`. This will pull all of the
rspec repos, build and install the gems, and then run the default `rake` task
in each, which will run their specs.

After the initial clone you can run `rake git:pull` to update to the latest bits.

Run `rake -T` to see the available tasks for dev mode.

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)

