require "aka/exceptions"
require 'pivotal_tracker'

# wrapper class to pivotal api client
class Aka::Pivotal
  
  def initialize(options)
    validate_options!(options)

    PivotalTracker::Client.token = options["token"]
    begin
      @project = PivotalTracker::Project.find(options["project_id"])
    rescue
      raise "pivotal project #{options["project_id"]} not found."
    end
    @username = options["username"]
  end
  
  def find_story(story_id)
    @project.stories.find(story_id) if story_id.to_i > 0
  end
  
  def start_story(story)
    story.update(:current_state => "started") if story
  end
  
  def pending_stories
    @project.stories.all(:state => "unstarted", :owned_by => @username, :limit => 5)
  end
  
  def display_values(stories)
    stories.map do |story|
      [story.id, story.name]
    end
  end
  
  def valid?
    @project.present?
  end
  
  private
  
  def validate_options!(options)
    if options.nil? || options.empty?
      raise Aka::AkaError, "pivotal missing configuration"
    end
    required_keys = %w(username token project_id)
    missing_keys = required_keys - options.keys
    if missing_keys.size > 0
      raise Aka::AkaError, "pivotal missing configuration: #{missing_keys.inspect}"
    end
  end
end