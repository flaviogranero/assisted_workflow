require 'spec_helper'
require 'assisted_workflow/git'

describe AssistedWorkflow::Git do
  before do
    @git = AssistedWorkflow::Git.new(:silent => true)
    stub(@git).system_error?{ false }
    stub(@git).system("git rev-parse --abbrev-ref HEAD"){ "flavio.00001.new_feature"}
  end
  
  it "creates a story branch" do
    mock(@git).system("git checkout -b flavio.00001.new_feature")
    @git.create_story_branch(story)
  end
  
  it "raises a git error when git command does not exit with success" do
    mock(@git).system_error?{ true }
    mock(@git).system("git checkout -b flavio.00001.new_feature")
    proc { @git.create_story_branch(story) }.must_raise AssistedWorkflow::GitError, "git command error"
  end
  
  
  it "rebases and push a feature branch" do
    mock(@git).system("git status --porcelain"){ "" }
    mock(@git).system("git checkout master")
    mock(@git).system("git pull --rebase")
    mock(@git).system("git checkout flavio.00001.new_feature")
    mock(@git).system("git rebase master")
    mock(@git).system("git push -u -f origin flavio.00001.new_feature")
    @git.rebase_and_push
  end
  
  it "raises when rebasing if there are not commited changes" do
    mock(@git).system("git status --porcelain"){ "changed_file.rb" }
    proc { 
      @git.rebase_and_push
    }.must_raise AssistedWorkflow::Error, "git: there are not commited changes"
  end
  
  it "returns the story_id from branch name" do
    @git.current_story_id.must_equal "00001"
  end
  
  it "return the current branch name" do
    @git.current_branch.must_equal "flavio.00001.new_feature"
  end
  
  it "returns the repository name assigned to origin" do
    mock(@git).system("git config --get remote.origin.url"){ "git@github.com:flaviogranero/assisted_workflow.git"}
    @git.repository.must_equal "flaviogranero/assisted_workflow"
  end
  
  describe "#is_merged?" do
    
    before do
      mock(@git).system("git status --porcelain"){ "" }
      mock(@git).system("git checkout flavio.00001.new_feature")
      mock(@git).system("git checkout master")
      mock(@git).system("git pull --rebase")
    end
    
    it "returns true if current branch is merged into master" do
      mock(@git).system("git branch --merged"){ "flavio.00001.new_feature" }
      @git.is_merged?.must_equal true
    end
    
    it "returns false if current branch is not merged into master" do
      mock(@git).system("git branch --merged"){ "flavio.00002.other_feature" }
      @git.is_merged?.must_equal false
    end
  end
  
  it "removes current branch and its remote version" do
    mock(@git).system("git push origin :flavio.00001.new_feature")
    mock(@git).system("git checkout master")
    mock(@git).system("git branch -D flavio.00001.new_feature")
    @git.remove_branch
  end
  
  private #==================================================================
  
  def story
    @story ||= PivotalTracker::Story.new(:id => "00001", :name => "New Feature", :description => "Feature description", :other_id => "flavio")
  end
end