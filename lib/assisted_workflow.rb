require "assisted_workflow/version"
require "assisted_workflow/exceptions"

module AssistedWorkflow
  autoload :ConfigFile, "assisted_workflow/config_file"
  autoload :Output, "assisted_workflow/output"
  
  module Addons
    autoload :Pivotal,    "assisted_workflow/addons/pivotal"
    autoload :Jira,    "assisted_workflow/addons/jira"
    autoload :Git,        "assisted_workflow/addons/git"
    autoload :Github,     "assisted_workflow/addons/github"
  end
end
