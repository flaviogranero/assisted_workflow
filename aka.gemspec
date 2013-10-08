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
  
  gem.add_dependency 'thor'
  
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
