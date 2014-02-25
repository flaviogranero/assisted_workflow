require "assisted_workflow/version"
require "assisted_workflow/exceptions"

module AssistedWorkflow
  autoload :ConfigFile, "assisted_workflow/config_file"
  autoload :Output,     "assisted_workflow/output"
  
  module Addons
    autoload :Pivotal, "assisted_workflow/addons/pivotal"
    autoload :Jira,    "assisted_workflow/addons/jira"
    autoload :Git,     "assisted_workflow/addons/git"
    autoload :Github,  "assisted_workflow/addons/github"
    
    # based on configuration keys, load the tracker addon
    def self.load_tracker(out, configuration)
      if configuration[:jira] && configuration[:jira][:project]
        Jira.new(out, configuration[:jira])
      elsif configuration[:pivotal] && configuration[:pivotal][:project_id]
        Pivotal.new(out, configuration[:pivotal])
      end
    end
  end
end
