require "aka/exceptions"

module Aka
  
  class GitError < AkaError; end
  
  class Git
    
    DESCRIPTION_LIMIT = 30
    
    # creates a new git branch based on story attributes
    # the branch name format is:
    # => story_onwer_username.story_id.story_name
    
    def create_story_branch(story)
      branch = branch_name(story)
      git "checkout -b #{branch}"
      # git "push --set-upstream origin #{branch}"
    end
    
    # run all the git steps required for a clean pull request
    def rebase_and_push
      branch = current_branch
      git "checkout master"
      git "pull --rebase"
      git "checkout #{branch}"
      git "rebase master"
      git "push -u origin #{branch} -f"
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
    
    private
    
    def git(command, options = {})
      puts "git #{command}" unless options[:silent] == true
      result = %x{git #{command}}
      unless $? == 0
        msg = ["git command error", options[:error]].compact.join(": ")
        raise GitError, msg
      end
      result
    end
    
    def branch_name(story)
      description = story.name.to_s.downcase.gsub(/\W/, "_").slice(0, DESCRIPTION_LIMIT)
      [story.other_id, story.id, description].join(".").downcase
    end
  end
end