# Rspec 2 Development Environment Setup

To setup your development environment run `rake`.

After the initial clone you can run `rake git:pull` to update to the latest bits.

The following tasks are available for dev mode:

    >>> rake --tasks
    (in /Users/chad/Projects/rubygems/rspec2/dev)
    rake dev:pair           # Pair dev, you must supply the PAIR1, PAIR2 arguments
    rake dev:solo           # Solo dev, removes any git pair markers
    rake gem:build          # Build gems
    rake gem:install        # Install all gems locally
    rake gem:release        # Release new versions to gemcutter
    rake gem:spec           # Rebuild gemspecs
    rake gem:uninstall      # Uninstall gems locally
    rake gem:write_version  # Write out a new version constant for each project.
    rake git:clone          # git clone all the repos the first time
    rake git:commit         # git commit all the repos with the same commit message
    rake git:diff           # git diff on all the repos
    rake git:pull           # git pull on all the repos
    rake git:push           # git push on all the repos
    rake git:reset          # git reset on all the repos
    rake git:status         # git status on all the repos
