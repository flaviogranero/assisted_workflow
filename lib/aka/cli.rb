require "aka"
require "yaml"
require "thor"

class Aka::CLI < Thor
  include Thor::Actions
  GLOBAL_CONFIG = File.expand_path(".akaconfig", ENV["HOME"])
  LOCAL_CONFIG = ".akaconfig"
  source_root(File.expand_path(File.join(__FILE__, "..", "templates")))
  
  map ["-v", "--version"] => :version
  
  desc "init", "Setup aka initial configuration in current project directory"
  def init
    # if !File.exists?(".akafile")
    copy_file "akaconfig.global.tt", GLOBAL_CONFIG
    copy_file "akaconfig.local.tt", LOCAL_CONFIG
    if File.exists?(".git")
      copy_file "commit-msg.tt", ".git/hooks/commit-msg"
    else
      raise Aka::Error, ".git folder not found"
    end
    say "set your own configuration editing the .akaconfig files or running:", :green
    say "\t$ aka config pivotal.fullname='Flavio Granero' --global"
    say "\t$ aka config pivotal.token=MYPIVOTALTOKEN --global"
    say "\t$ aka config github.token=MYGITHUBOAUTHTOKEN --global"
    say "\t$ aka config pivotal.project_id=00001"
  end
  
  desc "start [STORY_ID]", "Start the pivotal story and create a new branch to receive the changes"
  def start(story_id=nil)
    check_akafile!
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
    check_akafile!
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
    check_akafile!
    story_id = git.current_story_id
    if story_id.to_i > 0
      if git.is_merged?
        say "removing local and remote feature branches"
        git.remove_branch
        say "well done! check your next stories using:", :green
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
  
  desc "config group.key=value", "Set configuration keys in local config file"
  method_option :global, :type => :boolean, :aliases => "-g", :desc => "Set configuration key in global configuration file (for all projects)"
  def config(*args)
    if args.empty?
      print_table configuration.to_hash
    else
      config_file.parse(args).save!
    end
  end
  
  no_tasks do
    def pivotal
      @pivotal ||= Aka::Pivotal.new(configuration[:pivotal])
    end
    
    def git
      @git ||= Aka::Git.new
    end
    
    def github
      @github ||= Aka::Github.new(configuration[:github])
    end
    
    def config_file
      @config_file ||= Aka::ConfigFile.new(akafile)
    end
    
    # loads all configuration, merging global and local values
    def configuration
      @configuration ||= begin
        Aka::ConfigFile.new(GLOBAL_CONFIG).merge_file(LOCAL_CONFIG)
      rescue TypeError
        raise Aka::Error, "Error on loading .akaconfig files. Please check the content format."
      end
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
      raise Aka::Error, "#{akafile} does not exist.\nmake sure you run `$ aka init` in your project folder." unless File.exist?(akafile)
    end

    def akafile
      case
        when options[:akafile] then options[:akafile]
        when options[:global] then GLOBAL_CONFIG
        else LOCAL_CONFIG
      end
    end
end