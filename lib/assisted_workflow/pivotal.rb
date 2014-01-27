require "assisted_workflow/exceptions"
require 'pivotal_tracker'

# wrapper class to pivotal api client
module AssistedWorkflow
  class Pivotal
  
    def initialize(options)
      validate_options!(options)

      PivotalTracker::Client.token = options["token"]
      begin
        @project = PivotalTracker::Project.find(options["project_id"])
      rescue
        raise AssistedWorkflow::Error, "pivotal project #{options["project_id"]} not found."
      end
      @fullname = options["fullname"]
      @username = options["username"]
    end
  
    def find_story(story_id)
      if story_id.to_i > 0
        story = @project.stories.find(story_id)
        story.other_id = @username || @fullname
        story.other_id = story.other_id.to_s.downcase.split.join
        story
      end
    end
  
    def start_story(story, options = {})
      if story
        story.update(options.merge(:current_state => "started"))
        raise AssistedWorkflow::Error, story.errors.first.to_s if story.errors.any?
      end
    end
  
    def finish_story(story)
      story.update(:current_state => finished_state(story)) if story
    end
  
    def pending_stories(options = {})
      states = ["unstarted"]
      states << "started" if options[:include_started]
      @project.stories.all(:state => states, :owned_by => @username, :limit => 5)
    end
  
    def display_values(stories, options = {})
      stories.map do |story|
        if options[:show_state]
          [story.id, story.current_state, story.name]
        else
          [story.id, story.estimate, story.name]
        end
      end
    end
  
    def valid?
      @project.present?
    end
  
    private
  
    def validate_options!(options)
      if options.nil? || options.empty?
        raise AssistedWorkflow::Error, "pivotal missing configuration"
      end
      required_keys = %w(fullname token project_id)
      missing_keys = required_keys - options.keys
      if missing_keys.size > 0
        raise AssistedWorkflow::Error, "pivotal missing configuration: #{missing_keys.inspect}"
      end
    end
  
    def finished_state(story)
      if story.story_type == "chore"
        "accepted"
      else
        "finished"
      end
    end
  end
end