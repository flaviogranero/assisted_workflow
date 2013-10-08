require "aka/version"

module Aka
  class Runner < Thor
    desc "init", "Unleashes homer to feed on your dotfiles"
    def init
      puts "Homer Unleashed !"
    end
  end
end
