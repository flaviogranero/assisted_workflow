require "aka"
require "yaml"
require "thor"

class Aka::Runner < Thor
  map ["-v", "--version"] => :version
  
  desc "setup", "Setup aka configuration in current project directory"
  method_option :global, :type => :boolean, :aliases => "-g", :desc => "Setup aka global configuration (for all projects)"
  def setup
    if options[:global]
      # TODO: generate the global .aka file in home directory
    else
      # TODO: generate the .aka file in current directory, with project config
    end
  end
  
  desc "start [STORY_ID]", "Start the pivotal story and create a new branch to receive the changes"
  def start(story_id=nil)
    story = pivotal.find_story(story_id)
    if story.nil?
      stories = pivotal.pending_stories
      output.show_stories(stories)
    else
      pivotal.start_story(story)
      git.create_story_branch
    end
  end
  
  desc "finish", "Finish the current story and creates a new pull request"
  def finish
    story = git.current_story
    github.create_pull_request(story)
    pivotal.finish_story(story)
  end
  
  desc "complete", "Check if the changes are merged into master, removing the current branch"
  def complete
    # TODO: check if current branch is merged into master, delete the branch
    if git.is_merged?
      git.remove_branch
    end
  end
  
  desc "version", "Display Aka gem version"
  def version
    puts Aka::VERSION
  end
  
  no_tasks do
    # def engine
    #   @engine ||= begin
    #     engine_class = Foreman::Engine::CLI
    #     engine = engine_class.new(options)
    #     engine
    #   end
    # end
  end
  
  private ######################################################################

    def error(message)
      puts "ERROR: #{message}"
      exit 1
    end

    def check_akafile!
      error("#{akafile} does not exist.") unless File.exist?(procfile)
    end

    def akafile
      case
        when options[:akafile] then options[:akafile]
        when options[:root]     then File.expand_path(File.join(options[:root], ".akaconfig"))
        else ".akaconfig"
      end
    end

    def options
      original_options = super
      return original_options unless File.exists?(".akaconfig")
      defaults = ::YAML::load_file(".akaconfig") || {}
      Thor::CoreExt::HashWithIndifferentAccess.new(defaults.merge(original_options))
    end
  
end