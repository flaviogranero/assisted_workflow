require "aka"
require "yaml"
require "thor"

class Aka::CLI < Thor
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
      print_title "pending stories"
      print_table(pivotal.display_values(stories))
      say "start one story using:", :green
      say "\t$ aka start [STORY_ID]"
    else
      say "starting story: #{story.name}", :green
      pivotal.start_story(story)
      git.create_story_branch
    end
  rescue Exception => e
    print_error_and_exit e
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
    def pivotal
      @pivotal ||= Aka::Pivotal.new(config[:pivotal])
    end
    
    # def engine
    #   @engine ||= begin
    #     engine_class = Foreman::Engine::CLI
    #     engine = engine_class.new(options)
    #     engine
    #   end
    # end
  end
  
  private ######################################################################
  
    def print_title(title)
      say "-" * title.length, :green
      say title.upcase, :green
      say "-" * title.length, :green
      
    end
    
    def print_error_and_exit(exception)
      say exception.message, :red
      exit 1
    end

    def check_akafile!
      error("#{akafile} does not exist.") unless File.exist?(akafile)
    end

    def akafile
      case
        when options[:akafile] then options[:akafile]
        when options[:root]     then File.expand_path(File.join(options[:root], ".akaconfig"))
        else ".akaconfig"
      end
    end

    def config
      @config ||= begin
        local_config = if File.exists?(".akaconfig")
           ::YAML::load_file(".akaconfig")
         else
           {}
         end
        global_file = File.expand_path(".akaconfig", ENV["HOME"])
        global_config = if File.exists?(global_file)
          ::YAML::load_file(global_file)
        else
          {}
        end
        Thor::CoreExt::HashWithIndifferentAccess.new(
          global_config.merge(local_config)
        )
      end
    end
  
end