# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'assisted_workflow/version'

Gem::Specification.new do |gem|
  gem.name          = "assisted_workflow"
  gem.version       = AssistedWorkflow::VERSION
  gem.authors       = ["Flavio Granero"]
  gem.email         = ["maltempe@gmail.com"]
  gem.summary       = %q{AW is a CLI tool to automate software development workflows based on github pull requests}
  gem.homepage      = "https://github.com/inaka/assisted_workflow"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.executables   = %w( aw )
  
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rr"
  gem.add_development_dependency "fakefs"
  
  gem.add_dependency "thor", "~> 0.18.1"
  gem.add_dependency "pivotal-tracker", "~> 0.5.12"
  gem.add_dependency "jiralicious", "~> 0.4.0"
  gem.add_dependency "octokit", "~> 2.0"
  gem.add_dependency "hashie", "~> 2.0.5"
  
  gem.description   = <<desc
  `aw` is a command line tool to automate software development workflows based on github pull requests.
desc

  gem.post_install_message = <<-message

                       `..::/++ooooooooo+/::--`                                 
                   `-:://:---....```......--::///:-.`                           
               `..-:::---.```            ```...----::-..`                       
              `.:///-`````                       .-:++::-`                      
            `///::`    :/+oo:.`                       -:/+/-                    
          ..-//.          ....`                         `.-/+/`                 
          :+/.`                                            .-://.               
        ``/+:                                               `.//-``             
       `::-.`  `.---`  ```                                    .-://`            
       `++`   `:sso++/+hmy-.`                                   .//-.`          
     `.-//`    -++---:/+o/`                            `         ``:+:          
     .----     .:::-.`````                            .--::.       :+/`         
     -::..     .:::-`                                 `.-++-`      :+/.`        
     -/:``     -++-.`                                   `:/::-     -/:-.        
     :/:`      -oo-.`                    ``.--.`         ``.-.     -:-..        
     :/:`      -++-.`                    ``.+ooo+/:+so.            -:-..        
     :/:`      -++:-`                     `.+o+++++oso.            -:-..        
     -/:.`     .::/+-                      `//:--//++/`            -/:..        
     .----      `.+s/.`                    `-:.                    :+/.`        
      `.//`       -:+ss:-.          ``.:/oso++-`                   :+:          
       `//.``       .-:+++///++++///++++/:--``                   ``:/:          
        .-::-        ``--:::+ss+/:::----.``                     `----.          
         `/+/`            ../s+-.```                            -//.``          
          .--++-    .::.`.:/:-.                               .-+ys.            
          ``:hds++:::/:` .++-`                             .:/oo+//::-          
        ``+oo////+yds+/-.-//.                         .--/++++/:-``:/:``        
        `.oso--://sho+////+/-`                  ```...::/++++/::.  -::--        
     ``.--:/:--:+/.`.:/shyss+:-..``````````.---::/+oso++/..-:://.    .++.`      
    `:/:``:++++/--     -:/++++ooooooooooooooooo++:-.``  `-:/+/`       --::-     
  `--``  `sdy/:.       -:::-.    `````````            -:/++-`          `/o/`    
  `-.   .-+o/``        .--//.                      .:///:.`             -::..`  
``...` `:///-          `.-++-                    `.:++::-               .--:-.  
.......:ss-``            `++:.`               `.-+o/:-                    ./+-  
 `.::.`.:/.``             `.:o+.``       ``./++o+-``                      `//-``
       `+o.                 `-:+++//:::/++++:-.`                           -----
       `++`                  ``--------::---.`                             `.-::
       `//.                      `.....``                                  ``-++
      `.//-...----------------..............----------------------------..---/oo


        AW, thanks for installing Assisted Workflow!
        ============================================

       Use the provided `aw` command-line tool to start a task creating a feature branch, submit a pull request with the changes and finish a task, keeping your repository clean. For more details, search for Inaka Workflow description. 
       Now, go to your project folder and start using it with:
       
       $ aw setup

       Cheers,
       Flavio

--------------------------------------------------------------------------------

message
  
end
