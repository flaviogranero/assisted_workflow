require "assisted_workflow/exceptions"
require "assisted_workflow/addons/base"
require "octokit"

module AssistedWorkflow::Addons
  
  class GithubStory < SimpleDelegator
    def initialize(issue)
      super
      @issue = issue
    end
    
    def id
      @issue.number
    end
    
    def name
      @issue.title
    end
    
    def description
      @issue.body.to_s.gsub("\r\n", "\n")
    end
    
    def other_id
      @issue.assignee.login
    end
    
    def current_state
      other_id
    end
    
    def labels
      @issue.labels.map(&:name)
    end
    
    def estimate
      labels.join(", ")
      # @issue.repository.name if @issue.repository
    end
    
    def issue
      @issue
    end
  end
  
  class Github < Base
    required_options :token, :repository
    
    def initialize(output, options = {})
      super
      @client = Octokit::Client.new(:access_token => options["token"])
      
      @repo = options["repository"]
      @username = @client.user.login
    end
    
    # Creates a pull request using current branch changes
    # 
    # @param repo [String] Repository name. inaka/assisted_workflow
    # @param branch [String] Branch name. flavio.0001.new_feature
    # @param story [Story] Pivotal story object
    # @return [Sawyer::Resource] The newly created pull request
    def create_pull_request(branch, story)
      log "submiting the new pull request"
      base = "master"
      pull_request = if story.is_a? GithubStory
        @client.create_pull_request_for_issue(@repo, base, branch, story.id)
      else
        title = "[##{story.id}] #{story.name}"
        @client.create_pull_request(@repo, base, branch, title, story.description)
      end
      
      if pull_request.nil?
        raise AssistedWorkflow::Error, "error on submiting the pull request"
      end
      
      url = pull_request._links.html.href
      log "new pull request at #{url}"
      url
    end
    
    def find_story(story_id)
      if !story_id.nil?
        log "loading story ##{story_id}"
        issue = @client.issue(@repo, story_id)
        story = GithubStory.new(issue) if issue
        story
      end
    end
    
    def start_story(story, options = {})
      log "starting story ##{story.id}"
      current_labels = story.labels
      current_labels.delete "finished"
      current_labels.push "started"
      @client.reopen_issue(@repo, story.id, :assignee => @username, :labels => current_labels)
    end
  
    def finish_story(story, options = {})
      log "finishing story ##{story.id}"
      current_labels = story.labels
      current_labels.delete "started"
      current_labels.push "finished"
      @client.reopen_issue(@repo, story.id, :assignee => @username, :labels => current_labels)
    end
    
    def pending_stories(options = {})
      log "loading pending stories"
      opt = {:state => "open"}
      opt[:assignee] = @username unless options[:include_started]
      issues = @client.issues(@repo, opt)
      issues.map do |issue|
        GithubStory.new(issue)
      end
    end
    
    def valid?
      @client.user_authenticated?
    end
  end
end