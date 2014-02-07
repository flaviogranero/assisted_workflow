require "assisted_workflow"
require "thor"

module AssistedWorkflow
  class CLI < Thor
    include Thor::Actions
    GLOBAL_CONFIG = File.expand_path(".awconfig", ENV["HOME"])
    LOCAL_CONFIG = ".awconfig"
    source_root(File.expand_path(File.join(__FILE__, "..", "templates")))
  
    # tasks shortcuts
    map ["-v", "--version"] => :version
    map "s" => :start
    map "u" => :submit
    map "f" => :finish
  
    desc "setup", "Setup initial configuration in current project directory"
    def setup
      copy_file "awconfig.global.tt", GLOBAL_CONFIG
      copy_file "awconfig.local.tt", LOCAL_CONFIG
      if File.exists?(".git")
        copy_file "commit-msg.tt", ".git/hooks/commit-msg"
        chmod ".git/hooks/commit-msg", "a+x"
      else
        raise AssistedWorkflow::Error, ".git folder not found"
      end
      say "set your own configuration editing the .awconfig files or running:", :green
      say_command "$ aw config pivotal.fullname='Flavio Granero' --global"
      say_command "$ aw config pivotal.token=MYPIVOTALTOKEN --global"
      say_command "$ aw config github.token=MYGITHUBOAUTHTOKEN --global"
      say_command "$ aw config pivotal.project_id=00001"
    end
  
    desc "start [STORY_ID]", "Start the pivotal story and create a new branch to receive the changes"
    method_option :all, :type => :boolean, :default => false, :aliases => "-a", :desc => "Show started and pending stories when no story_id is provided"
    method_option :estimate, :type => :numeric, :aliases => "-e", :desc => "Sets the story estimate when starting"
    def start(story_id=nil)
      check_awfile!
      story = pivotal.find_story(story_id)
      if story.nil?
        stories = pivotal.pending_stories(:include_started => options[:all])
        out.print_stories "pending stories", stories, options
        out.next_command "start a story using:", "$ aw start [STORY_ID]"
      else
        pivotal.start_story(story, :estimate => options[:estimate])
        out.print_story story
        git.create_story_branch(story)
        out.next_command "after commiting your changes, submit a pull request using:", "$ aw submit"
      end
    end
  
    desc "submit", "Submits the current story creating a new pull request"
    def submit
      check_awfile!
      story_id = git.current_story_id
      say "loading story info"
      story = pivotal.find_story(story_id)
      if story
        say "preparing local branch"
        git.rebase_and_push
        say "submiting the new pull request"
        pr = github.create_pull_request(git.repository, git.current_branch, story)
        say "finishing the story"
        pivotal.finish_story(story, :note => pr._links.html.href)
        say "new pull request: #{pr._links.html.href}", :yellow
        say "after pull request approval, remove the feature branch using:", :green
        say_command "$ aw finish"
      else
        raise AssistedWorkflow::Error, "story not found, make sure a feature branch in active"
      end
    end
  
    desc "finish", "Check if the changes are merged into master, removing the current feature branch"
    def finish
      check_awfile!
      story_id = git.current_story_id
      if story_id.to_i > 0
        if git.is_merged?
          say "removing local and remote feature branches"
          git.remove_branch
          say "well done! check your next stories using:", :green
          say_command "$ aw start"
        else
          say "this branch is not merged into master yet", :yellow
        end
      else
        raise AssistedWorkflow::Error, "story not found, make sure a feature branch in active"
      end
    end
  
    desc "version", "Display assisted_workflow gem version"
    def version
      say AssistedWorkflow::VERSION
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
  
    desc "thanks", "Aw, Thanks!", :hide => true
    def thanks
      say "you're welcome!", :on_magenta
    end
  
  
    no_tasks do
      def out
        @out ||= Output.new(self.shell)
      end
      
      def pivotal
        @pivotal ||= Addons::Pivotal.new(out, configuration[:pivotal])
      end
    
      def git
        @git ||= Addons::Git.new(out)
      end
    
      def github
        @github ||= Addons::Github.new(out, configuration[:github])
      end
    
      def config_file
        @config_file ||= ConfigFile.new(awfile)
      end
    
      # loads all configuration, merging global and local values
      def configuration
        @configuration ||= begin
          ConfigFile.new(GLOBAL_CONFIG).merge_file(LOCAL_CONFIG)
        rescue TypeError
          raise AssistedWorkflow::Error, "Error on loading .awconfig files. Please check the content format."
        end
      end
    end
  
    class << self
      def start(given_args=ARGV, config={})
        super
      rescue AssistedWorkflow::Error => e
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
    
      def check_awfile!
        raise AssistedWorkflow::Error, "#{awfile} does not exist.\nmake sure you run `$ aw setup` in your project folder." unless File.exist?(awfile)
      end

      def awfile
        case
          when options[:awfile] then options[:awfile]
          when options[:global] then GLOBAL_CONFIG
          else LOCAL_CONFIG
        end
      end
  end
end