require 'rake'
require 'fileutils'
require 'pathname'
require 'bundler'
require 'time'
require 'date'

Projects = ['rspec-expectations', 'rspec-mocks', 'rspec-core', 'rspec', 'rspec-rails', 'rspec-support']
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
      puts "#{'='*3} #{dir} #{'='*(40 - dir.length)}"
      begin
        Bundler.with_clean_env do
          ENV['NOEXEC_DISABLE'] = "1" # prevent rubygems-bundler from interfering
          sh command
        end
      rescue Exception => e
        puts e.backtrace
      end
      puts
    end
  end
end

def each_project(options = {})
  projects = Projects
  projects -= Array(options[:except])

  projects.each do |project|
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
    run_command "bin/rake build"
  end

  task :clean_pkg_directories do
    run_command "rm -rf pkg"
  end

  desc "Tag each repo, push the tags, push the gems"
  task :release do
    run_command "bin/rake release"
  end

  desc "Install all gems locally"
  task :install do
    run_command "bin/rake install"
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
  task :co, [:version] => :checkout

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
  run_command "bin/rake clobber"
end

namespace :bundle do
  desc "unlock the gem bundles"
  task :unlock do
    sh "find . -name 'Gemfile.lock' | xargs rm"
  end

  desc "install the gem bundles"
  task :install do
    `gem install bundler` unless `gem list`.split("\n").detect {|g| g =~ /^bundler/}
    `bundle install --binstubs`
    run_command 'bundle install --binstubs --gemfile ./Gemfile'
  end
end

def github_client
  @github_client ||= begin
    require 'octokit'
    token  = File.read(BaseRspecPath + "config/github_oauth_token.txt").strip
    Octokit::Client.new(:access_token => token)
  end
end

BASE_BRANCH = ENV.fetch('BRANCH', 'master')
BASE_BRANCH_MAJOR_VERSION = if BASE_BRANCH == 'master'
                              3
                            else
                              Integer(BASE_BRANCH[/^\d+/])
                            end

def create_pull_request(project_name, branch, base=BASE_BRANCH)
  github_client.create_pull_request(
    "rspec/#{project_name}", base, branch,
    "Updates from rspec-dev (#{Date.today.iso8601})",
    "These are some updates, generated from rspec-dev's rake tasks."
  )
end

namespace :travis do
  ReadFile = Struct.new(:file_name, :contents, :mode)

  def assert_clean_git_status(name)
    unless `git status`.include?('nothing to commit (working directory clean)')
      abort "#{name} has uncommitted changes"
    end
  end

  def each_project_with_common_travis_build(&b)
    except = %w[ rspec rspec-rails ]
    except << "rspec-support" if BASE_BRANCH_MAJOR_VERSION < 3
    each_project(except: except, &b)
  end

  def travis_files_with_comments
    file_names = Dir["./travis/**/{*,.*}"].select { |f| File.file?(f) }
    files = file_names.map { |f| ReadFile.new(f.sub(%r|\./travis/|, ''), File.read(f), File.stat(f).mode) }

    files.map do |file|
      comments_added = false
      lines = file.contents.lines.each_with_object([]) do |line, all|
        if !comments_added && !line.start_with?('#!')
          all.concat([
            "# This file was generated on #{Time.now.iso8601} from the rspec-dev repo.\n",
            "# DO NOT modify it by hand as your changes will get lost the next time it is generated.\n\n",
          ])
          comments_added = true
        end

        all << line
      end

      ReadFile.new(file.file_name, lines.join, file.mode)
    end
  end

  def update_travis_files_in_repos
    branch_name = "update-travis-build-scripts-#{Date.today.iso8601}-for-#{BASE_BRANCH}"

    each_project_with_common_travis_build { |proj| assert_clean_git_status(proj) }
    files = travis_files_with_comments

    each_project_with_common_travis_build do |name|
      sh "git checkout #{BASE_BRANCH}"
      sh "git pull --rebase"
    end

    each_project_with_common_travis_build do |name|
      sh "git checkout -b #{branch_name}"

      files.each do |file|
        full_file_name = ReposPath + "#{name}/#{file.file_name}"
        File.write(full_file_name, file.contents)
        FileUtils.chmod(file.mode, full_file_name) # ensure it is executable
      end

      File.write("./maintenance-branch", BASE_BRANCH) unless File.exist?('./maintenance-branch')
      sh "git rm ./maintenence-branch" if File.exist?('./maintenence-branch')
      sh "git rm script/test_all" if File.exist?('script/test_all')

      sh "git add ."
      sh "git commit -m 'Updated travis build scripts (from rspec-dev)'"
    end

    branch_name
  end

  desc "Update travis build files"
  task :update_files do
    update_travis_files_in_repos
  end

  desc "Updates the travis files and creates a PR"
  task :create_pr_with_updates do
    branch = update_travis_files_in_repos

    each_project_with_common_travis_build do |name|
      sh "git push origin #{branch}"
      create_pull_request(name, branch)
      sh "git checkout #{BASE_BRANCH} && git branch -D #{branch}" # no need to keep it around
    end
  end
end

task :setup => ["git:clone", "bundle:install"]

task :default do
  run_command "bin/rake"
end

desc "publish cukes to relishapp.com"
task :relish, :version do |_, args|
  raise "rake relish[VERSION]" unless args[:version]
  run_command "bin/rake relish['#{args[:version]}']", :except => ['rspec']
end

desc "generate release notes from changelogs"
task :release_notes, :target do |_, args|
  target = args[:target] || 'blog'
  ['rspec-core', 'rspec-expectations', 'rspec-mocks', 'rspec-rails'].each do |project|
    lines = []
    Dir.chdir("repos/#{project}") do
      log = File.readlines("Changelog.md").map(&:chomp)
      header = log.shift.split
      lines << "### #{project}-#{header[1]}"
      full_changelog_link = log.shift
      if target == 'email'
        lines << full_changelog_link[1..-2].gsub('](', ': ')
      else
        lines << full_changelog_link
      end
      while log.first !~ /^###/
        lines << log.shift.chomp
      end
      lines << ""
      lines << ""
    end
    puts lines.join("\n")
  end
end

namespace :doc do
  desc "generate docs"
  task :generate do
    Dir.chdir("repos") do
      sh "ln -s rspec-core/README.md RSpecCore.md" unless test ?f, "RSpecCore.md"
      sh "ln -s rspec-expectations/README.md RSpecExpectations.md" unless test ?f, "RSpecExpectations.md"
      sh "ln -s rspec-mocks/README.md RSpecMocks.md" unless test ?f, "RSpecMocks.md"
      sh "ln -s rspec-rails/README.md RSpecRails.md" unless test ?f, "RSpecRails.md"
      sh "yardoc"
      sh "rm RSpecCore.md"
      sh "rm RSpecExpectations.md"
      sh "rm RSpecMocks.md"
      sh "rm RSpecRails.md"
      sh %q|ruby -pi.bak -e "gsub(/Documentation by YARD \d+\.\d+\.\d+/, 'RSpec 2.8')" doc/_index.html|
      sh %q|ruby -pi.bak -e "gsub(/<h1 class=\"alphaindex\">Alphabetic Index<\/h1>/, '')" doc/_index.html|
      sh "cp doc/_index.html doc/index.html"
    end
  end

  desc "clobber generated docs"
  task :clobber do
    Dir.chdir("repos") do
      sh "rm -rf .yardoc"
      sh "rm -rf doc"
    end
  end

  desc "publish generated docs"
  task :publish do
    Dir.chdir("repos") do
      `rsync -av --delete doc david@davidchelimsky.net:/www/api.rspec.info`
    end
  end
end

task :rdoc => ["doc:clobber", "doc:generate"]

task :contributors do
  Projects.inject("") do |logs, dir|
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
  puts "#{authors.count} contributors: "
  puts authors.compact.join(", ")
end
