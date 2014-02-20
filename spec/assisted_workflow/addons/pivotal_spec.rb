require 'spec_helper'
require 'assisted_workflow/addons/pivotal'

describe AssistedWorkflow::Addons::Pivotal do
  
  before do
    @configuration = {
      "token" => "mypivotaltoken",
      "project_id" => "1",
      "username" => "flavio",
      "fullname" => "Flavio Granero"
    }
    # stubs
    @project = PivotalTracker::Project.new(:id => "1")
    stub(PivotalTracker::Project).find(@configuration["project_id"]){ @project }
    
    @pivotal = AssistedWorkflow::Addons::Pivotal.new(nil, @configuration)
  end
  
  it "initializes a valid pivotal addon" do
    assert @pivotal.valid?
  end
  
  it "requires fullname" do
    proc { 
      AssistedWorkflow::Addons::Pivotal.new(
        nil,
        @configuration.reject{|k,v| k == "fullname"}
      )
    }.must_raise AssistedWorkflow::Error, "pivotal missing configuration:[fullname]"
  end
  
  it "requires token" do
    proc {
      AssistedWorkflow::Addons::Pivotal.new(
        nil,
        @configuration.reject{|k,v| k == "token"}
      )
    }.must_raise AssistedWorkflow::Error, "pivotal missing configuration:[token]"
  end

  it "requires project_id" do
    proc { 
      AssistedWorkflow::Addons::Pivotal.new(
        nil,
        @configuration.reject{|k,v| k == "project_id"}
      )
    }.must_raise AssistedWorkflow::Error, "pivotal missing configuration:[project_id]"
  end
  
  it "finds a story by id" do
    mock(PivotalTracker::Story).find("100001", @project.id) do |story_id, project_id|
      story_stub(:id => story_id, :project_id => project_id)
    end
    
    story = @pivotal.find_story("100001")
    story.id.must_equal "100001"
    story.other_id.must_match /flavio/
  end
  
  it "returns pending stories" do
    mock(PivotalTracker::Story).all(@project, :state => ["unstarted", "started"], :owned_by => @configuration["fullname"], :limit => 5) do |project|
      [
        story_stub(:id => "100001", :project_id => project.id),
        story_stub(:id => "100002", :project_id => project.id)
      ]
    end
    
    stories = @pivotal.pending_stories(:include_started => true)
    stories.size.must_equal 2
  end
  
  it "starts a story" do
    story = story_stub(:id => "100001", :project_id => @project.id)
    @pivotal.start_story(story, :estimate => "3")
    story.current_state.must_match /started/
    story.estimate.must_equal "3"
    story.errors.must_be_empty
  end
  
  it "finishes a story" do
    story = story_stub(:id => "100001", :project_id => @project.id)
    any_instance_of(PivotalTracker::Note) do |klass|
      stub(klass).create{ true }
    end
    
    @pivotal.finish_story(story, :note => "pull_request_url")
    story.current_state.must_match /finished/
    story.errors.must_be_empty
  end
  
  private #===================================================================
  
  def story_stub(attributes = {})
    story = PivotalTracker::Story.new(attributes)
    stub(story).update do |attrs|
      story.send(:update_attributes, attrs)
      story
    end
    
    story
  end
end