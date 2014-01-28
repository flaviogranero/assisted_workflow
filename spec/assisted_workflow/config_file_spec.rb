require 'spec_helper'
require 'assisted_workflow/config_file'

describe AssistedWorkflow::ConfigFile do
  
  before do
    FakeFS.activate!
    FakeFS::FileSystem.clear
    @config_file = AssistedWorkflow::ConfigFile.new(".awconfig")
  end
  
  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end
  
  it "parses new configuration" do
    @config_file.parse  ["pivotal.token=mypivotaltoken",
                        "github.user=flaviogranero"]
    @config_file[:pivotal][:token].must_match /mypivotaltoken/
    @config_file[:github][:user].must_match /flaviogranero/
  end
  
  it "stores and loads config values" do
    @config_file.parse "pivotal.token=mypivotaltoken"
    @config_file.save!
    config = AssistedWorkflow::ConfigFile.new(".awconfig")
    config[:pivotal][:token].must_match /mypivotaltoken/
  end
  
  it "merges 2 configuration files" do
    @config_file.parse "pivotal.token=mypivotaltoken"
    @config_file.save!
    
    config = AssistedWorkflow::ConfigFile.new(".awconfig2")
    config.parse "github.user=flaviogranero"
    config.merge_file(".awconfig")
    
    config[:pivotal][:token].must_match /mypivotaltoken/
    config[:github][:user].must_match /flaviogranero/
  end
end