require 'spec_helper'
require 'assisted_workflow/addons/github'

describe AssistedWorkflow::Addons::Github do
  before do
    @configuration = {
      "token" => "mygithubtoken",
    }
    # stubs
    @client = Object.new
    stub(@client).user_authenticated?{ true }
    stub(Octokit::Client).new{ @client }
    
    @github = AssistedWorkflow::Addons::Github.new(nil, @configuration)
  end
  
  it "initializes a valid github wrapper" do
    assert @github.valid?
  end
  
  it "requires token" do
    proc { 
      AssistedWorkflow::Addons::Github.new(nil, {})
    }.must_raise AssistedWorkflow::Error, "github missing configuration:[token]"
  end
  
  it "creates a new valid pull request" do
    mock(@client).create_pull_request("flaviogranero/assisted_workflow", "master", "flavio.00001.new_feature", "[#00001] New Feature", "Feature description"){ pull_request }
    @github.create_pull_request(
      "flaviogranero/assisted_workflow", "flavio.00001.new_feature", story
    ).must_match /flaviogranero\/assisted_workflow\/pull\/1/
  end
  
  it "raises on creating an invalid pull request" do
    mock(@client).create_pull_request("flaviogranero/invalid_repo", "master", "flavio.00001.new_feature", "[#00001] New Feature", "Feature description"){ nil }
    proc { 
      @github.create_pull_request(
        "flaviogranero/invalid_repo", "flavio.00001.new_feature", story
      )
    }.must_raise AssistedWorkflow::Error, "error on submiting the pull request"
  end
  
  private #==================================================================
  
  def story
    @story ||= PivotalTracker::Story.new(:id => "00001", :name => "New Feature", :description => "Feature description")
  end
  
  def pull_request
    agent = Sawyer::Agent.new("", {:links_parser => Sawyer::LinkParsers::Simple.new})
    data = {_links: {html: {href: "https://github.com/flaviogranero/assisted_workflow/pull/1"}}}
    Sawyer::Resource.new(agent, data)
  end
end