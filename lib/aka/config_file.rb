require "hashie"
require "yaml"

module Aka
  # special hash class to allow configuration management
  class ConfigHash < Hash
    include Hashie::Extensions::MergeInitializer
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::DeepMerge
  end
  
  # class providing methods to load, manage and save configuration files
  class ConfigFile
    # parse a command line arguments into configuration keys
    # Example:
    #   pivotal.token=mypivotaltoken
    #   => {:pivotal => {:token => "mypivotaltoken"}}
    def parse(args)
      Array(args).each do |values|
        keys, value = values.split("=")
        keys.split(".").reverse.each do |k|
          value = {k => value}
        end
        @hash.deep_merge!(value)
      end
      self
    end
    
    # dumps the configuration values to a file in yaml format
    def save!
      File.open(@akafile, 'w'){ |f| f.write(@hash.to_yaml) }
    end
    
    def [](key)
      @hash[key]
    end
    
    def to_hash
      @hash.dup
    end
    
    # merges other config file into the current one
    def merge_file(file)
      other_config = ConfigFile.new(file)
      @hash.deep_merge!(other_config.to_hash)
      self
    end
    
    def initialize(akafile)
      @akafile = akafile
      @hash = if File.exists?(@akafile)
        ConfigHash.new(::YAML::load_file(@akafile) || {})
      else
        ConfigHash.new
      end
    end
  end
end