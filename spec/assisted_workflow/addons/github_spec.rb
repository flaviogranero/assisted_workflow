require 'spec_helper'
require 'pivotal_tracker'
require 'assisted_workflow/addons/github'

describe AssistedWorkflow::Addons::Github do
  before do
    @configuration = {
      "token" => "mygithubtoken",
      "repository" => "fakeuser/fakerepo"
    }
    @client = client_stub
    stub(Octokit::Client).new{ @client }
    
    @github = AssistedWorkflow::Addons::Github.new(nil, @configuration)
  end
  
  it "initializes a valid github wrapper" do
    assert @github.valid?
  end
  
  it "requires token and repository configuration" do
    proc { 
      AssistedWorkflow::Addons::Github.new(nil, {})
    }.must_raise AssistedWorkflow::Error, "github missing configuration:[token,repository]"
  end
  
  it "creates a new valid pull request from a pivotal story" do
    mock(@client).create_pull_request("fakeuser/fakerepo", "master", "fakeuser.00001.new_feature", "[#00001] New Feature", "Feature description"){ pull_request }
    @github.create_pull_request(
      "fakeuser.00001.new_feature", story
    ).must_match /fakeuser\/fakerepo\/pull\/1/
  end
  
  it "creates a new valid pull request from a github story" do
    mock(@client).create_pull_request_for_issue("fakeuser/fakerepo", "master", "fakeuser.00001.new_feature", 10){ pull_request }
    @github.create_pull_request(
      "fakeuser.00001.new_feature",
      AssistedWorkflow::Addons::GithubStory.new(gh_issue(:number => 10))
    ).must_match /fakeuser\/fakerepo\/pull\/1/
  end
  
  it "raises on creating an invalid pull request" do
    mock(@client).create_pull_request("fakeuser/fakerepo", "master", "fakeuser.00001.new_feature", "[#00001] New Feature", "Feature description"){ nil }
    proc { 
      @github.create_pull_request(
        "fakeuser.00001.new_feature", story
      )
    }.must_raise AssistedWorkflow::Error, "error on submiting the pull request"
  end
  
  it "finds a story by id" do
    mock(@client).issue(@configuration["repository"], "10") do |repo, issue_number|
      gh_issue(:number => issue_number)
    end
    
    story = @github.find_story("10")
    story.id.must_equal "10"
    story.other_id.must_match /fakeuser/
  end
  
  it "returns pending stories" do
    mock(@client).issues(@configuration["repository"], {
      :state => "open", :assignee => "fakeuser"
    }) do
      [ gh_issue ]
    end
    
    stories = @github.pending_stories(:include_started => false)
    stories.size.must_equal 1
  end
  
  it "starts a story" do
    mock(@client).reopen_issue(@configuration["repository"], gh_issue.number, :assignee => "fakeuser", :labels => ["bug","started"]){ true }
    @github.start_story(AssistedWorkflow::Addons::GithubStory.new(gh_issue))
  end
  
  it "finishes a story" do
    mock(@client).reopen_issue(@configuration["repository"], gh_issue.number, :assignee => "fakeuser", :labels => ["bug","finished"]){ true }
    @github.finish_story(AssistedWorkflow::Addons::GithubStory.new(gh_issue))
  end
  
  private #==================================================================
  
  def story
    @story ||= PivotalTracker::Story.new(:id => "00001", :name => "New Feature", :description => "Feature description")
  end
  
  def agent_stub
    Sawyer::Agent.new("", {:links_parser => Sawyer::LinkParsers::Simple.new})
  end
  
  def gh_issue(attributes = {})
    @gh_issue ||= Sawyer::Resource.new(agent_stub, attributes.merge({
                    :assignee => {:login => "fakeuser"},
                    :labels => [{:name => "bug"}]
                  }))
  end
  
  def pull_request
    Sawyer::Resource.new(agent_stub, {_links: {html: {href: "https://github.com/fakeuser/fakerepo/pull/1"}}})
  end
  
  def client_stub
    client = Object.new
    user = Object.new
    stub(user).login{ "fakeuser" }
    stub(client).user{ user }
    stub(client).user_authenticated?{ true }
    client
  end
end