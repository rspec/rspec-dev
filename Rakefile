require 'rake'
require 'fileutils'
require 'pathname'

UsingBundler = !!ENV['BUNDLE_GEMFILE']

Projects = ['rspec-expectations', 'rspec-mocks', 'rspec-core', 'rspec', 'rspec-rails']
BaseRspecPath = Pathname.new(Dir.pwd)
ReposPath = BaseRspecPath.join('repos')

def run_command(command, opts={})
  projects = if opts[:except]
               Projects - [opts[:except]].flatten
             elsif opts[:only]
               [opts[:only]].flatten
             else
               Projects
             end
  projects.each do |dir|
    next if [opts[:except]].flatten.compact.include?(dir)
    path = ReposPath.join(dir)
    FileUtils.cd(path) do
      puts "="*50
      puts "# " + path.to_s.sub(/#{File.dirname(__FILE__)}\//,'')
      puts "# " + command
      puts "-"*40
      begin
        sh command
      rescue Exception => e
        puts e.backtrace
      end
      puts
    end
  end
end

def each_project
  Projects.each do |project|
    Dir.chdir("repos/#{project}") do
      puts "="*50
      puts "# #{project}"
      puts "-"*40
      yield project
      puts
    end
  end
end

task :make_repos_directory do
  FileUtils.mkdir_p ReposPath
end

desc "run an arbitrary command against all repos"
task :run, :command do |t, args|
  run_command args[:command]
end

namespace :gem do
  desc "Write out a new version constant for each project.  You must supply VERSION"
  task :write_version, :version do |t, args|
    raise("You must supply VERSION") unless args[:version]
    Projects.each do |project|
      file = Dir.chdir("repos/#{project}") { File.expand_path(`git ls-files **/version.rb`.chomp) }
      current_content = File.read(file)
      new_content = current_content.gsub(/STRING = ['"][^'"]+['"]/, "STRING = '#{args[:version]}'")

      puts "Writing out version #{args[:version]} for #{project}"
      File.open(file, "w") { |f| f.write(new_content) }
    end
  end

  desc "Build gems"
  task :build => [:clean_pkg_directories] do
    run_command "rake build"
  end

  task :clean_pkg_directories do
    run_command "rm -rf pkg"
  end

  desc "Tag each repo, push the tags, push the gems"
  task :release do
    run_command("rake release")
  end

  desc "Install all gems locally"
  task :install do
    run_command "rake install"
  end

  desc "Uninstall gems locally"
  task :uninstall do
    Projects.each do |project|
      path = ReposPath.join(project)
      FileUtils.cd(path) do
        system "gem uninstall --all --executables --ignore-dependencies #{project}"
      end
    end
  end
end

namespace :dev do
  desc "Pair dev, you must supply the PAIR1, PAIR2 arguments"
  task :pair do
    raise("You must supply PAIR1, and PAIR2 to pair dev") unless ENV['PAIR1'] && ENV['PAIR2']
    run_command "pair #{ENV['PAIR1']} #{ENV['PAIR2']}"
  end

  desc "Solo dev, removes any git pair markers"
  task :solo do
    run_command "pair"
  end
end

namespace :git do
  { :status => nil, :push => nil, :reset => '--hard', :diff => nil }.each do |command, options|
    desc "git #{command} on all the repos"
    task command => :clone do
      run_command "git #{command} #{options}".strip
    end
  end

  desc 'git pull on all the repos'
  task :pull => [:clone] do
    run_command "git pull --rebase"
  end

  desc 'git checkout repos'
  task :checkout, :version  do |t, args|
    raise("rake git:checkout[VERSION]") unless args[:version]
    run_command "git checkout #{args[:version]}"
  end

  task :st => :status
  task :update => :pull

  desc "git clone all the repos the first time"
  task :clone => :make_repos_directory do
    url_prefix = `git config --get remote.origin.url`[%r{(^.*)/rspec-dev}, 1]

    FileUtils.cd(ReposPath) do
      Projects.each do |repo|
        unless File.exists?(repo)
          system "git clone #{url_prefix}/#{repo}.git"
        end
      end
    end

  end

  desc "git commit all the repos with the same commit message"
  task :commit, :message do |t, args|
    raise("You must supply a message to git:commit:\n\n  rake git:commit[\"this is the commit message\"]\n\n") unless args[:message]
    run_command "git commit -am '#{args[:message]}'"
  end
end

task :clobber do
  run_command "rake clobber"
end

namespace :bundle do
  desc "unlock the gem bundles"
  task :unlock do
    sh "find . -name 'Gemfile.lock' | xargs rm"
  end

  desc "install the gem bundles"
  task :install, :binstubs do |t, args|
    `gem install bundler` unless `gem list`.split("\n").detect {|g| g =~ /^bundler/}
    binstubs = if args.binstubs
                 "--binstubs=#{args.binstubs}"
               else
                 "--binstubs"
               end
    `bundle install #{binstubs}`
    Bundler.with_clean_env do
      run_command "bundle install #{binstubs} --gemfile ./Gemfile", :except => 'rspec-rails'
      run_command 'thor gemfile:use 3.1.0', :only => 'rspec-rails'
    end
  end
end

task :setup, :binstubs do |t, args|
  Rake::Task['git:clone'].invoke
  Rake::Task['bundle:install'].invoke(args.binstubs)
end

task :runtests, :rake do |t, args|
  if UsingBundler
    Bundler.with_clean_env do
      ENV.delete 'BUNDLE_GEMFILE'
      run_command args.rake || 'bin/rake'
    end
  else
    run_command args.rake || 'rake'
  end
end

task :default => :runtests

task :authors do
  logs = Projects.inject("") do |logs, dir|
    path = ReposPath.join(dir)
    FileUtils.cd(path) do
      logs << `git log`
    end
    logs
  end
  authors = logs.split("\n").grep(/^Author/).
    map{|l| l.sub(/Author: /,'')}.
    map{|l| l.split('<').first}.
    map{|l| l.split('and')}.flatten.
    map{|l| l.split('+')}.flatten.
    map{|l| l.split(',')}.flatten.
    map{|l| l.strip}.
    uniq.compact.reject{|n| n == ""}.sort
  puts "#{authors.count} authors: "
  puts authors.compact.join(", ")
end
