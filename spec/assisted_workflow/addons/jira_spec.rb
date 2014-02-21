require 'spec_helper'
require 'assisted_workflow/addons/jira'

describe AssistedWorkflow::Addons::Jira do
  
  before do
    @configuration = {
      "username" => "jirauser",
      "password" => "jirapass",
      "uri" => "aw.atlassian.net",
      "project" => "AW",
      "unstarted" => "Backlog",
      "started" => "Started",
      "finished" => "Finished"
    }
    @jira = AssistedWorkflow::Addons::Jira.new(nil, @configuration)
  end
  
  it "initializes a valid jira addon" do
    assert @jira.valid?
  end
  
  it "requires username" do
    proc { 
      AssistedWorkflow::Addons::Jira.new(
        nil,
        @configuration.reject{|k,v| k == "username"}
      )
    }.must_raise AssistedWorkflow::Error, "jira missing configuration:[username]"
  end
  
  it "requires password" do
    proc { 
      AssistedWorkflow::Addons::Jira.new(
        nil,
        @configuration.reject{|k,v| k == "password"}
      )
    }.must_raise AssistedWorkflow::Error, "jira missing configuration:[password]"
  end
  
  it "requires url" do
    proc { 
      AssistedWorkflow::Addons::Jira.new(
        nil,
        @configuration.reject{|k,v| k == "uri"}
      )
    }.must_raise AssistedWorkflow::Error, "jira missing configuration:[url]"
  end
  
  it "requires project" do
    proc { 
      AssistedWorkflow::Addons::Jira.new(
        nil,
        @configuration.reject{|k,v| k == "project"}
      )
    }.must_raise AssistedWorkflow::Error, "jira missing configuration:[project]"
  end
  
  it "requires statuses configuration" do
    ["unstarted", "started", "finished"].each do |status|
      proc { 
        AssistedWorkflow::Addons::Jira.new(
          nil,
          @configuration.reject{|k,v| k == status}
        )
      }.must_raise AssistedWorkflow::Error, "jira missing configuration:[#{status}]"
    end
  end
  
  it "finds a story by id" do
    mock(Jiralicious::Issue).find("aw-01") do |story_id|
      story_stub(:jira_key => story_id)
    end
    
    story = @jira.find_story("aw-01")
    story.id.must_equal "aw-01"
    story.other_id.must_match /jirauser/
  end
  
  it "returns pending stories" do
    query = "project=AW and assignee='jirauser' and status in ('Backlog','Started')"
    mock(Jiralicious).search(query, :max_results => 5){ search_results_stub }
    
    stories = @jira.pending_stories(:include_started => true)
    stories.size.must_equal 2
  end
  
  it "starts a story" do
    story = story_stub(:jira_key => "aw-01")
    mock_transition(story.id, "2")
    @jira.start_story(story)
  end
  
  it "finishes a story" do
    story = story_stub(:id => "aw-01")
    any_instance_of(Jiralicious::Issue::Comment) do |klass|
      stub(klass).add("pull_request_url"){ true }
    end
    mock_transition(story.id, "3")
    assert @jira.finish_story(story, :note => "pull_request_url")
  end
  
  private #===================================================================
  
  def story_stub(attributes = {})
    stub(Jiralicious::Issue::Comment).find_by_key{ Jiralicious::Issue::Comment.new }
    stub(Jiralicious::Issue::Watchers).find_by_key{ nil }
    
    default = {
      "fields" => {"assignee" => {"name" => "jirauser"}}
    }
    Jiralicious::Issue.new(default.merge(attributes))
  end
  
  def search_results_stub
    search_data = {
      "issues" => [story_stub(:jira_key => "aw-01"), story_stub(:jira_key => "aw-02")],
      "offset" => 0,
      "num_results" => 2
    }
    Jiralicious::SearchResult.new(search_data)
  end
  
  def mock_transition(story_id, status_id)
    url = "#{Jiralicious.rest_path}/issue/#{story_id}/transitions"
    response = Object.new
    stub(response).parsed_response do
      {"transitions" => [
        {"id" => "1", "name" => "Backlog"},
        {"id" => "2", "name" => "Started"},
        {"id" => "3", "name" => "Finished"},
      ]}
    end
    mock(Jiralicious::Issue).get_transitions(url){ response }
    mock(Jiralicious::Issue).transition(url, {"transition" => status_id})
  end
end