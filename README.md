# Aka

A CLI tool to automate software development workflows based on github pull requests.

* [Inaka Workflow](https://github.com/inaka/inaka_corp/wiki/Inaka-Workflow)
* [Github Workflow](http://scottchacon.com/2011/08/31/github-flow.html)

## Installation

Add this line to your application's Gemfile:

    gem 'aka'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aka
    
Or, if you are using homebrew and want to make aka system wide avaliable, use brew-gem:

    $ brew install brew-gem
    $ brew gem aka

## Initial Setup

TODO: Write usage instructions here

##Requirements

`aka` assumes you're using an 'origin' remote.  If you are not,
either add an 'origin' remote that points to the GitHub repository you want to submit pull requests.

##Private repositories

To submit pull requests for your private repositories you have set up your aka config for github

    $ aka config --global github.token your_githubtoken123456789

You must generate your OAuth token for command line use, see how to [generate oauth token](https://help.github.com/articles/creating-an-oauth-token-for-command-line-use).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## To-do

1. setup task to check global and local configs
2. setup installing a git-hook to include story id in commit message
3. allow individual tasks like pivotal:start, github:submit, freckle:log

#### Inspiration

1. https://github.com/ddollar/foreman
2. https://github.com/github/hub
3. https://github.com/schacon/git-pulls
