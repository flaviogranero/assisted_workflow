require "assisted_workflow/exceptions"
require "assisted_workflow/addons/base"

module AssistedWorkflow::Addons
  
  class GitError < AssistedWorkflow::Error; end
  
  class Git < Base
    
    DESCRIPTION_LIMIT = 30
    
    def initialize(output, options = {})
      super
      @command_options = {:raise_error => true}.merge(options)
    end
    
    # creates a new git branch based on story attributes
    # the branch name format is:
    # => story_onwer_username.story_id.story_name
    def create_story_branch(story)
      log "creating the feature branch"
      branch = branch_name(story)
      git "checkout -b #{branch}"
      # git "push --set-upstream origin #{branch}"
    end
    
    # run all the git steps required for a clean pull request
    def rebase_and_push
      log "preparing local branch"
      check_everything_commited!
      branch = current_branch
      git "checkout master"
      git "pull --rebase"
      git "checkout #{branch}"
      git "rebase master"
      git "push -u -f origin #{branch}"
    end
    
    # returns the current story id based on branch name
    def current_story_id
      current_branch.split(".")[1]
    end
    
    # returns the current local branch name
    def current_branch
      git("rev-parse --abbrev-ref HEAD", :silent => true)
    end
    
    # returns the repository name assigned to origin following the format:
    # owner/project
    def repository
      url = git("config --get remote.origin.url", :error => "cannot find 'origin' remote repository url")
      url.gsub("git@github.com:", "").gsub("https://github.com/", "").gsub(/\.git$/, "").chomp
    end
    
    # check if current branch is merged into master
    def check_merged!
      check_everything_commited!
      branch = current_branch
      git "checkout master"
      git "pull --rebase"
      merged = git("branch --merged").include?(branch)
      git "checkout #{branch}"
      unless merged
        raise AssistedWorkflow::Error, "this branch is not merged into master"
      end
      merged
    end
    
    # removes current branch and its remote version
    def remove_branch
      log "removing local and remote feature branches"
      branch = current_branch
      git "push origin :#{branch}", :raise_error => false
      git "checkout master"
      git "branch -D #{branch}"
    end
    
    private #=================================================================
    
    def git(command, options = {})
      options = @command_options.merge(options)
      puts "git #{command}" unless options[:silent] == true
      result = system("git #{command}")
      if system_error? && options[:raise_error]
        msg = ["git command error", options[:error]].compact.join(": ")
        raise GitError, msg
      end
      result
    end
    
    def system(command)
      %x{#{command}}.chomp
    end
    
    def system_error?
      $? != 0
    end
    
    def branch_name(story)
      description = story.name.to_s.downcase.gsub(/\W/, "_").slice(0, DESCRIPTION_LIMIT)
      [story.other_id, story.id, description].join(".").downcase
    end
    
    def not_commited_changes
      git("status --porcelain", :silent => true).split("\n")
    end
    
    def check_everything_commited!
      raise AssistedWorkflow::Error, "git: there are not commited changes" unless not_commited_changes.empty?
    end
  end
end