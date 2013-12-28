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
    say "pending", :yellow
  end
  
  desc "start [STORY_ID]", "Start the pivotal story and create a new branch to receive the changes"
  def start(story_id=nil)
    story = pivotal.find_story(story_id)
    if story.nil?
      stories = pivotal.pending_stories
      print_title "pending stories"
      print_table(pivotal.display_values(stories))
      say "start a story using:", :green
      say "\t$ aka start [STORY_ID]"
    else
      say "creating the feature branch"
      git.create_story_branch(story)
      say "starting story: #{story.name}"
      pivotal.start_story(story)
      say "after commiting your changes, submit a pull request using:", :green
      say "\t$ aka submit"
    end
  end
  
  desc "submit", "Submits the current story creating a new pull request"
  def submit
    story_id = git.current_story_id
    say "loading story info"
    story = pivotal.find_story(story_id)
    if story
      say "preparing local branch"
      git.rebase_and_push
      say "submiting the new pull request"
      pr = github.create_pull_request(git.repository, git.current_branch, story)
      say "finishing the story"
      pivotal.finish_story(story)
      say "new pull request: #{pr._links.html.href}", :yellow
      say "after pull request approval, remove the feature branch using:", :green
      say "\t$aka finish"
    else
      raise Aka::Error, "story not found, make sure a feature branch in active"
    end
  end
  
  desc "finish", "Check if the changes are merged into master, removing the current feature branch"
  def finish
    story_id = git.current_story_id
    if story_id.to_i > 0
      if git.is_merged?
        say "removing local and remote feature branches"
        git.remove_branch
        say "well done! check out you next stories using:", :green
        say "\t$ aka start"
      else
        say "this branch is not merged into master yet", :yellow
      end
    else
      raise Aka::Error, "story not found, make sure a feature branch in active"
    end
  end
  
  desc "version", "Display Aka gem version"
  def version
    say Aka::VERSION
  end
  
  no_tasks do
    def pivotal
      @pivotal ||= Aka::Pivotal.new(config[:pivotal])
    end
    
    def git
      @git ||= Aka::Git.new
    end
    
    def github
      @github ||= Aka::Github.new(config[:github])
    end
    
  end
  
  class << self
    def start(given_args=ARGV, config={})
      super
    rescue Aka::Error => e
      config[:shell].say e.message, :red
      exit(1)
    end
  end
  
  private ######################################################################
  
    def print_title(title)
      say "-" * title.length, :green
      say title.upcase, :green
      say "-" * title.length, :green
      
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
      rescue TypeError
        raise Aka::Error, "Error on loading .akaconfig file. Please check the content format."
      end
    end
  
end