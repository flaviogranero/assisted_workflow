# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aka/version'

Gem::Specification.new do |gem|
  gem.name          = "aka"
  gem.version       = Aka::VERSION
  gem.authors       = ["Flavio Granero"]
  gem.email         = ["maltempe@gmail.com"]
  gem.summary       = %q{CLI tool to automate Inaka Workflow tasks}
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.executables   = %w( aka )
  
  gem.add_dependency "thor", "~> 0.18.1"
  gem.add_dependency "pivotal-tracker", "~> 0.5.12"
  gem.add_dependency "octokit", "~> 2.0"
  gem.add_dependency "hashie", "~> 2.0.5"
  
  gem.description   = <<desc
  `aka` is a command line utility to automate Inaka Workflow tasks.

  Usage:

      $ aka init
  
desc

  gem.post_install_message = <<-message

------------------------------------------------------------

                  Welcome to Inaka Team!!
                  =======================

       Use aka tool to start, finish and merge tasks 
       into the Inaka Workflow.

       Cheers,
       Flavio

------------------------------------------------------------

message
  
end
