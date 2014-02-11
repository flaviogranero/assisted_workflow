module AssistedWorkflow
  
  # a helper class to provide custom shell print methods
  class Output < SimpleDelegator
    def initialize(shell)
      super
      @shell = shell
    end
    
    # prints a highlighted title section
    def print_title(title)
      say "-" * title.length, :green
      say title.upcase, :green
      say "-" * title.length, :green
    end
    
    # prints as table with stories data
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
    
    def next_command(title, commands, &block)
      say title, :green
      _commands = Array(commands)
      yield(_commands) if block_given?
      _commands.each do |command|
        print_wrapped command, :indent => 2
      end
    end
    
  end
end