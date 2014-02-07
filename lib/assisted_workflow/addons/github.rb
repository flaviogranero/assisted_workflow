require "assisted_workflow/exceptions"
require "assisted_workflow/addons/base"
require "octokit"

module AssistedWorkflow::Addons
  
  class Github < Base
    required_options :token
    
    def initialize(options = {})
      super
      @client = Octokit::Client.new(:access_token => options["token"])
    end
    
    # Creates a pull request using current branch changes
    # 
    # @param repo [String] Repository name. flaviogranero/assisted_workflow
    # @param branch [String] Branch name. flavio.0001.new_feature
    # @param story [Story] Pivotal story object
    # @return [Sawyer::Resource] The newly created pull request
    def create_pull_request(repo, branch, story)
      base = "master"
      title = "[##{story.id}] #{story.name}"
      pull_request = @client.create_pull_request(repo, base, branch, title, story.description)
      if pull_request.nil?
        raise AssistedWorkflow::Error, "error on submiting the pull request"
      else
        pull_request
      end
    end
    
    def valid?
      @client.user_authenticated?
    end
  end
end