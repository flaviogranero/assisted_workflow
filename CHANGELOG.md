### Unreleased

### 0.3.0

* enchancements
  * Adding `jira` support to be used as story tracker, replacing pivotal
  * Adding `github` issues support as another story tracker option

### 0.2.1

* bug fix
  * Removing duplicated git add-on

### 0.2.0

* enchancements
  * Moving libs to the new addons namespace, with a base class
  * Introducing an output helper to deal with shell prints
  
### 0.1.4

* bug fix
  * Fixing a bug preventing git commands to be executed
  
### 0.1.3
    
* enchancements
  * Tasks shortcuts
  * Adding specs to libraries
  * Setting up travis-ci
  
### 0.1.2

* enchancements
  * pivotal: adding pull request link as a story note on submiting
  * pivotal: showing story description
  * start command: --all option to include started stories
  
* bug fix
  * finish command: do not raise if remote branch does not exists
  * setup command: chmod git commit-msg hook to allow execution

### 0.1.1

* enchancements
  * renaming aka to aw (assisted_workflow)
  
### 0.1.0

* AssistedWorkflow::CLI
* AssistedWorkflow::Git
* AssistedWorkflow::Github
* AssistedWorkflow::Pivotal
* AssistedWorkflow::ConfigFile