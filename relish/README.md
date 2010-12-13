<div style="float: right; padding-left:5px"><a href="http://pragprog.com/titles/achbd/the-rspec-book" style="border:0" target="_blank"><img src="http://www.pragprog.com/images/covers/190x228/achbd.jpg" style="height:182px;width:152px;"></a></div>

RSpec is a Behaviour-Driven Development tool for Ruby programmers. BDD is an approach to software development that combines Test-Driven Development, Domain Driven Design, and Acceptance Test-Driven Planning. RSpec helps you do the TDD part of that equation, focusing on the documentation and design aspects of TDD.

### Getting started

$ gem install rspec

Start with a very simple example that expresses some basic desired behaviour.

    # bowling_spec.rb
    
    describe Bowling do
      describe "#score" do
        it "returns 0 for all gutter game" do
          bowling = Bowling.new
          20.times { bowling.hit(0) }
          bowling.score.should == 0
        end
      end
    end

Run the example and watch it fail.

<pre style="color:red;">
$ rspec bowling_spec.rb 
  uninitialized constant Object::Bowling (NameError)
</pre>

Now write just enough code to make it pass.

<pre>
# bowling_spec.rb

require './bowling'
...
</pre>

<pre>
# bowling.rb

class Bowling
  def hit(pins)
  end

  def score
    0
  end
end
</pre>

Run the example and bask in the joy that is green.

<pre style="color:green;">
$ rspec bowling_spec.rb --color --format doc

Bowling
  #score
    returns 0 for all gutter game

Finished in 0.00057 seconds
1 example, 0 failures
</pre>

### Documentation

This is the official documentation site for RSpec-2. Much of the documentation
you see here is written with another BDD tool called
[Cucumber](http://github.com/aslakhellesoy/cucumber), which, like RSpec,
provides _executable documentation_. The Cucumber features you see here have
all been run against RSpec's codebase, serving as specification, documentation
_and_ regression tests of the behaviour.

### Release Policy

Since the release of RSpec-2.0, RSpec follows the [Rubygems Rational Versioning
Policy](http://docs.rubygems.org/read/chapter/7). We are working toward
compliance with [Semantic Versioning](http://semver.org/), but that is a bit
down the road. You can read those documents for more detail, but the short
version is this:

Release numbers have three parts:

* Major
* Minor
* Patch

For example, the recent 2.3.0 release means:

* Major: 2
* Minor: 3
* Patch: 0

The different parts follow the following conventions:

* Patch releases have only bug fixes.
* Minor releases have bug fixes and/or new functionality.
* Major releases have bug fixes and/or new functionality _possibly including breaking changes_.

#### What this means for RSpec users

The first thing you'll notice is more frequent minor and major releases. We are
already at rspec-2.3.0 instead of 2.0.5 because we've steadily added new
features, so the 2.1, 2.2, and 2.3 releases were inappropriate for a patch
release.

The real benefit is that you can now safely use a [Pessamistic Version
Constraint](http://docs.rubygems.org/read/chapter/16#page74) (e.g. "~> 2.3")
with confidence that you won't accidentally absorb breaking changes.

### Upgrading from RSpec-1

If you are upgrading from rspec-1, or beta versions of rspec-2, be sure to review the Upgrade information for each project:

* [rspec-core/Upgrade.markdown](http://github.com/rspec/rspec-core/tree/master/Upgrade.markdown)
* [rspec-expectations/Upgrade.markdown](http://github.com/rspec/rspec-expectations/tree/master/Upgrade.markdown)
* [rspec-rails/Upgrade.markdown](http://github.com/rspec/rspec-rails/tree/master/Upgrade.markdown)

### Help make this documentation better!

Please submit feedback (and patches!) on this documentation to:

* [rspec-core issues](http://github.com/rspec/rspec-core/issues)
* [rspec-expectations issues](http://github.com/rspec/rspec-expectations/issues)
* [rspec-mocks issues](http://github.com/rspec/rspec-mocks/issues)
* [rspec-rails issues](http://github.com/rspec/rspec-rails/issues)

