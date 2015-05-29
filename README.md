# Assisted Workflow (aw)

[![Gem Version](https://badge.fury.io/rb/assisted_workflow.png)](http://badge.fury.io/rb/assisted_workflow) [![Build Status](https://travis-ci.org/inaka/assisted_workflow.png?branch=master)](https://travis-ci.org/inaka/assisted_workflow) [![Code Climate](https://codeclimate.com/github/inaka/assisted_workflow.png)](https://codeclimate.com/github/inaka/assisted_workflow)

AW is a CLI tool to automate software development workflows based on github pull requests.

* [Github Workflow](http://scottchacon.com/2011/08/31/github-flow.html)

Here in [Inaka](http://inaka.net) we have the following workflow steps:

1. Start a pivotal/jira/github story, moving to a new git branch for the new feature/bug fix
2. Commit the changes, pushing to a new remote branch
3. Submit a pull-request, allowing other team member to review the code, and merge into master if everything is ok
4. Finish the story, removing both local and remote feature branches
5. Deploy master branch.

For more details, please read more about the [Inaka's Development Workflow](https://github.com/inaka/assisted_workflow/wiki/Inaka's-Development-Flow).

This gem provides a command line tool to automate tasks related with `start`, `submit` and `finish` steps.

## Contact Us
For **questions** or **general comments** regarding the use of this library, please use our public
[hipchat room](https://www.hipchat.com/gpBpW3SsT).

If you find any **bugs** or have a **problem** while using this library, please [open an issue](https://github.com/inaka/assisted_workflow/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at [inaka.github.io](http://inaka.github.io)

## Installation

Add this line to your application's Gemfile:

    gem 'assisted_workflow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install assisted_workflow
    
## Initial Setup

`assisted_worflow` uses `.awconfig` files to store your credentials and settings. When running the `setup` command, it will create a global config  file placed in your home folder, and one config file specific for a project, inside the project folder. In order to start using it, go to your project folder and run:

    $ aw setup
    
You need to run this command for all projects you want to use `assisted_worflow`.

If this is your initial setup, you need to inform your pivotal and github keys to allow api access. Do this using the config command:

    $ aw config pivotal.fullname='Flavio Granero' --global
    $ aw config pivotal.username='flavio' --global
    $ aw config pivotal.token=MYPIVOTALTOKEN --global
    $ aw config github.token=MYGITHUBOAUTHTOKEN --global
    
Note we're using the --global flag, to store this info in the global config file, valid for all projects. You can get your pivotal Api Token in your [profile page](https://www.pivotaltracker.com/profile) and the github api key [following the instructions to generate an oauth token](https://help.github.com/articles/creating-an-access-token-for-command-line-use).

After the global setup, you need to inform the pivotal project_id, storing it in the project .awconfig file:

    $ aw config pivotal.project_id=00001

You may want to store the local .awconfig file into the project repository, preventing other users to run this setup step for every project.

## Usage

Having the setup step done, you are able to use the following commands to automate your workflow:

* __$ aw start__

 List your next 5 pending stories in pivotal, showing a table with each story id, estimate and title. In order to include the already started stories in the list, run it with the `-a` flag.
 
* __$ aw start STORY_ID__

 Find and mark a pivotal story as `started`, moving to a new git branch named with your pivotal username, story id and title. If the story is not estimated yet, you'll see an error message. You can set the estimate before starting it using the option `-e 3`, for instance.

* __$ aw submit__

 Submit the current story branch, creating a new github pull request. Once you're done with the story changes and everything is commited, run submit command to rebase the feature branch with master and submit it, creating a new pull request. The pull request url will be added as a note in the pivotal story, marking it as `finished`.
 
* __$ aw finish__

 Run finish command from a feature branch to check if the pull request has been merged into master, and to remove the local and remote branches safety.
 
There are shortcuts for these 3 main commands. Use __$ aw s__ to start, __$ aw u__ to submit and __$ aw f__ to finish a story.

##Requirements

`assisted_workflow` assumes you're using an 'origin' remote. If you are not,
either add an 'origin' remote that points to the GitHub repository you want to submit pull requests.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## To-do

1. add github issues support
2. refactor addons to a base class, with access to a shell output wrapper.
