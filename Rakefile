require 'rake'
require 'fileutils'
require 'pathname'
require 'bundler'
require 'time'
require 'date'
require 'erb'

Projects = ['rspec', 'rspec-core', 'rspec-expectations', 'rspec-mocks', 'rspec-rails', 'rspec-support']
UnDocumentedProjects = %w[ rspec rspec-support ]
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
        Bundler.clean_system(command)
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

desc "Updates the rspec.github.io docs"
task :update_docs, [:version, :branch, :website_path] do |t, args|
  abort "You must have ag installed to generate docs" if `which ag` == ""
  args.with_defaults(:website_path => "../rspec.github.io")
  run_command "git checkout #{args[:branch]} && git pull --rebase"
  each_project :except => UnDocumentedProjects do |project|
    cmd = "bundle install && RUBYOPT='-I#{args[:website_path]}/lib' bundle exec yard --plugin rspec-docs-template --output-dir #{args[:website_path]}/source/documentation/#{args[:version]}/#{project}/"
    puts cmd
    Bundler.clean_system(cmd)
    in_place =
      if RUBY_PLATFORM =~ /darwin/ # if this is os x then we must modify sed
        "-i ''"
      else
        "-i''"
      end
    Bundler.clean_system %Q{pushd #{args[:website_path]}; ag -l href=\\"\\\(?:..\/\\\)*css | xargs -I{} sed #{in_place} 's/href="\\\(..\\\/\\\)*css/href="\\\/stylesheets\\\/docs/' {}; popd}
    Bundler.clean_system %Q{pushd #{args[:website_path]}; ag -l src=\\"\\\(?:..\/\\\)*js | xargs -I{} sed #{in_place} 's/src="\\\(..\\\/\\\)*js/src="\\\/javascripts\\\/docs/' {}; popd}
  end
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

desc "Changes to a different branch on all repos and re-bundles"
task :change_branch, [:version] => ["git:checkout", "git:pull", "bundle:unlock", "bundle:install"]

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
        unless File.exist?(repo)
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

  def update_travis_files_in_repos
    update_files_in_repos('travis build scripts') do |name|
      around_update_travis_build do
        travis_files_with_comments.each do |file|
          full_file_name = ReposPath.join(name, file.file_name)
          full_file_name.write(file.contents)
          full_file_name.chmod(file.mode) # ensure executables are set
        end

        update_maintenance_branch
      end
    end
  end

  def travis_files_with_comments
    travis_root = BaseRspecPath.join('travis')
    file_names = Pathname.glob(travis_root.join('**', '{*,.*}')).select do |f|
      f.file?
    end

    file_names.map do |file|
      comments_added = false
      lines = file.each_line.each_with_object([]) do |line, all|
        if !comments_added && !line.start_with?('#!')
          all.concat([
            "# This file was generated on #{Time.now.iso8601} from the rspec-dev repo.\n",
            "# DO NOT modify it by hand as your changes will get lost the next time it is generated.\n\n",
          ])
          comments_added = true
        end

        all << line
      end

      ReadFile.new(
        file.relative_path_from(travis_root),
        lines.join,
        file.stat.mode
      )
    end
  end

  def update_maintenance_branch
    File.write("./maintenance-branch", BASE_BRANCH) unless File.exist?('./maintenance-branch')
  end

  def run_if_exists(script_file)
    sh script_file if File.exist?(script_file)
  end

  def around_update_travis_build
    run_if_exists './script/before_update_travis_build.sh'
    yield if block_given?
  ensure
    run_if_exists './script/after_update_travis_build.sh'
  end

  desc "Update travis build files"
  task :update_files do
    update_travis_files_in_repos
  end

  desc "Updates the travis files and creates a PR"
  task :create_pr_with_updates do
    force_update update_travis_files_in_repos
  end
end

namespace :common_markdown_files do
  def update_common_markdown_files_in_repos
    update_files_in_repos('common markdown files', ' [ci skip]') do |name|
      common_markdown_files_with_comments(name).each do |file|
        full_file_name = ReposPath.join(name, file.file_name)
        full_file_name.write(file.contents)
        full_file_name.chmod(file.mode) # ensure executables are set
      end
    end
  end

  def github_template_file?(file)
    file.basename.to_s =~ /ISSUE_TEMPLATE/
  end

  def common_markdown_files_with_comments(project_name)
    markdown_root = BaseRspecPath.join('common_markdown_files')
    file_names = Pathname.glob(markdown_root.join('**', '{*,.*}')).select do |f|
      f.file?
    end

    file_names.map do |file|
      comments_added = false
      content = markdown_file_content(file, project_name)

      lines = content.each_line.each_with_object([]) do |line, all|
        if !github_template_file?(file) && !comments_added && !line.start_with?('#!')
          all.concat([
            "<!---\n",
            "This file was generated on #{Time.now.iso8601} from the rspec-dev repo.\n",
            "DO NOT modify it by hand as your changes will get lost the next time it is generated.\n",
            "-->\n\n",
          ])
          comments_added = true
        end

        all << line
      end

      ReadFile.new(
        file.relative_path_from(markdown_root).sub(/\.erb$/, ''),
        lines.join,
        file.stat.mode
      )
    end
  end

  ERBRenderer = Struct.new(:project_name, :contents) do
    def render
      # Our `binding` makes `project_name` available to the ERB template.
      ERB.new(contents).result(binding)
    end
  end

  def markdown_file_content(file, project_name)
    raw_contents = file.read
    return raw_contents unless file.extname == ".erb"
    ERBRenderer.new(project_name, raw_contents).render
  end

  desc "Update common markdown files"
  task :update_files do
    update_common_markdown_files_in_repos
  end

  desc "Updates the common markdown files files and creates a PR"
  task :create_pr_with_updates do
    force_update update_common_markdown_files_in_repos
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
  ['rspec-core', 'rspec-expectations', 'rspec-mocks', 'rspec-rails', 'rspec-support'].each do |project|
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

desc "Lists stats generated from the logs for the provided commit ranges"
task :version_stats, :commit_ranges do |t, args|
  projects = Projects - ["rspec"]

  puts
  puts "### Combined: "
  puts
  version_stats = VersionStats.new(args[:commit_ranges].split("|"), projects)
  version_stats.print

  projects.each do |project|
    puts
    puts "### #{project}: "
    puts
    version_stats = VersionStats.new(args[:commit_ranges].split("|"), project)
    version_stats.print
  end
end

def assert_clean_git_status(name)
  unless `git status --porcelain`.empty?
    abort "#{name} has uncommitted changes"
  end
end

def confirm_branch_name(name)
  return name unless system("git show-branch #{name} > /dev/null 2>&1")

  puts "Branch #{name} already exists, delete? [Y/n] or rename new branch? [r[ename] <name>]"
  case input = STDIN.gets.downcase
  when /^y/i
    `git branch -D #{name}`
  when /^r(?:ename)? (.*)$/
    name = $1
  when /^n/i
  else
    abort "Unknown option: #{input}"
  end

  name
end

def each_project_with_common_build(&b)
  except = %w[ rspec ]
  except << "rspec-support" if BASE_BRANCH_MAJOR_VERSION < 3
  each_project(:except => except, &b)
end

def force_update(branch)
  each_project_with_common_build do |name|
    unless system("git push origin #{branch}")
      puts "Push failed, force? (y/n)"
      if STDIN.gets.downcase =~ /^y/
        sh "git push origin +#{branch}"
      end
      create_pull_request(name, branch) rescue nil
    else
      create_pull_request(name, branch)
    end
    sh "git checkout #{BASE_BRANCH} && git branch -D #{branch}" # no need to keep it around
  end
end

def update_files_in_repos(purpose, suffix='')
  branch_name = "update-#{purpose.gsub ' ', '-'}-#{ENV.fetch('BRANCH_DATE',Date.today.iso8601)}-for-#{BASE_BRANCH}"

  each_project_with_common_build do |proj|
    assert_clean_git_status(proj)
  end

  each_project_with_common_build do |name|
    sh "git checkout #{BASE_BRANCH}"
    sh "git pull --rebase"
  end

  each_project_with_common_build do |name|
    branch_name = confirm_branch_name(branch_name)
    sh "git checkout -b #{branch_name}"

    yield name

    sh "git add ."
    sh "git commit -m 'Updated #{purpose} (from rspec-dev)#{suffix}'"
  end

  branch_name
end

class VersionStats
  attr_reader :commit_ranges, :dirs

  def initialize(commit_ranges, dirs)
    @commit_ranges = commit_ranges
    @dirs = Array(dirs)
  end

  def print
    puts "* **Total Commits**: #{commits}"
    puts "* **Merged pull requests**: #{merged_pull_requests}"
    puts "* **#{authors.count} contributors**: #{authors.join(", ")}"
  end

  def authors
    @authors ||= begin
      logs = @dirs.each_with_object("") do |dir, _logs|
        cd(dir) do
          commit_ranges.each do |range|
            _logs << `git log #{range} | grep Author | sort | uniq`
          end
        end
      end

      logs.split("\n").
        map{|l| l.sub(/Author: /,'')}.
        map{|l| l.split('<').first}.
        map{|l| l.split(' and ')}.flatten.
        map{|l| l.split('+')}.flatten.
        map{|l| l.split(',')}.flatten.
        map{|l| l.strip}.
        uniq.compact.reject{|n| n == ""}.sort
    end
  end

  def cd(dir)
    path = ReposPath.join(dir)
    FileUtils.cd(path) { return yield }
  end

  def commits
    @commits ||= count_commits("")
  end

  def merged_pull_requests
    @merged_pull_requests ||= count_commits('grep -v Revert | grep "Merge pull request" |')
  end

private

  def count_commits(command_before_count)
    @dirs.reduce(0) do |count_1, dir|
      commit_ranges.reduce(0) do |count_2, range|
        cd(dir) { Integer(`git log #{range} --oneline | #{command_before_count} wc -l`) } + count_2
      end + count_1
    end
  end
end
