require "aka/version"
require "aka/exceptions"

module Aka
  autoload :Pivotal,    "aka/pivotal"
  autoload :Git,        "aka/git"
  autoload :Github,     "aka/github"
  autoload :ConfigFile, "aka/config_file"
end
