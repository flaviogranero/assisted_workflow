require 'spec_helper'
require 'assisted_workflow/addons/jira'

describe AssistedWorkflow::Addons::Jira do
  
  before do
    @configuration = {
      "username" => "jirauser",
      "password" => "jirapass",
      "uri" => "aw.atlassian.net"
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
  
  
  it "finds a story by id" do
    mock(Jiralicious::Issue).find("web-1") do |story_id|
      story_stub(:id => story_id)
    end
    
    story = @jira.find_story("web-01")
    story.id.must_equal "web-01"
    # story.other_id.must_match /flavio/
  end
  # 
  # it "returns pending stories" do
  #   mock(jiraTracker::Story).all(@project, :state => ["unstarted", "started"], :owned_by => @configuration["fullname"], :limit => 5) do |project|
  #     [
  #       story_stub(:id => "100001", :project_id => project.id),
  #       story_stub(:id => "100002", :project_id => project.id)
  #     ]
  #   end
  #   
  #   stories = @jira.pending_stories(:include_started => true)
  #   stories.size.must_equal 2
  # end
  # 
  # it "starts a story" do
  #   story = story_stub(:id => "100001", :project_id => @project.id)
  #   @jira.start_story(story, :estimate => "3")
  #   story.current_state.must_match /started/
  #   story.estimate.must_equal "3"
  #   story.errors.must_be_empty
  # end
  # 
  # it "finishes a story" do
  #   story = story_stub(:id => "100001", :project_id => @project.id)
  #   any_instance_of(jiraTracker::Note) do |klass|
  #     stub(klass).create{ true }
  #   end
  #   
  #   @jira.finish_story(story, :note => "pull_request_url")
  #   story.current_state.must_match /finished/
  #   story.errors.must_be_empty
  # end
  # 
  # it "returns arrays to be printed" do
  #   
  # end
  
  private #===================================================================
  
  def story_stub(attributes = {})
    story = Jiralicious::Issue.new(attributes)
    # stub(story).update do |attrs|
    #   story.send(:update_attributes, attrs)
    #   story
    # end
    
    story
  end
end