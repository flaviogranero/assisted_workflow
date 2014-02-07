module AssistedWorkflow
  
  # a helper class to provide custom shell print methods
  class Output < SimpleDelegator
    def initialize(shell)
      super
      @shell = shell
    end
    
    def print_title(title)
      say "-" * title.length, :green
      say title.upcase, :green
      say "-" * title.length, :green
    end
    
    def print_stories(title, stories, options = {})
      print_title title
      rows = stories.map do |story|
        if options[:all]
          [story.id, story.current_state, story.name]
        else
          [story.id, story.estimate, story.name]
        end
      end
      print_table(rows)
    end
    
    def print_story(story)
      print_wrapped story.name, :indent => 2
      print_wrapped story.description, :indent => 2
    end
    
    def next_command(title, command)
      say title, :green
      print_wrapped command, :indent => 2
    end
    
  end
end