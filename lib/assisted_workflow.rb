require "assisted_workflow/version"
require "assisted_workflow/exceptions"

module AssistedWorkflow
  autoload :Pivotal,    "assisted_workflow/pivotal"
  autoload :Git,        "assisted_workflow/git"
  autoload :Github,     "assisted_workflow/github"
  autoload :ConfigFile, "assisted_workflow/config_file"
end
