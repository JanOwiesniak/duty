[![Build Status](https://travis-ci.org/JanOwiesniak/duty.svg?branch=master)](https://travis-ci.org/JanOwiesniak/duty) [![Inline docs](http://inch-ci.org/github/JanOwiesniak/duty.svg?branch=master)](http://inch-ci.org/github/JanOwiesniak/duty)

# Duty

Craft.
Don't battle.
Do your duty, let me handle the rest.

## Installation

```
$ gem install duty
```

## Add executable to your $PATH

```
$ export PATH="$PATH:$HOME/path/to/duty/bin"
```

## Add shell completion

This gem supports a simple shell completion for
[Bash](https://www.gnu.org/software/bash/) and [ZSH](http://www.zsh.org).
To enable this feature load the completion functions:

```
$ source duty.completion
```

## Usage

```
$ duty <task> [<args>]
```

## List of official duty plugins

* [duty-git](https://github.com/JanOwiesniak/duty-git)

## Extend duty with your own plugins

* Create a new file that implements the plugin behaviour
* Create a .duty file e.g. in your project dir

### How does a duty plugin looks like?

Example: `/path/to/your/duty-plugins/my_duty_plugin.rb`

```ruby
require 'duty'

module MyDutyPlugin
  def self.tasks
    [
      MyDutyTasks::MyFirstTask,
      MyDutyTasks::ContinueFeature
    ]
  end
end

module MyDutyTasks
  class MyFirstTask < ::Duty::Tasks::Base
  end

  class ContinueFeature < ::Duty::Tasks::Base
    def self.description
      "Continue on an already existing feature"
    end

    def self.usage
      "duty continue-feature <feature-name>"
    end

    def valid?
      !!feature_name
    end

    # Everthing in here will be executed sequential
    def execute

      # Execute ruby code
      ruby("Do something useful in ruby") { Object.new }

      # Execute something on the shell
      sh("Checkout `feature/#{feature_name}` branch") { "git checkout feature/#{feature_name}" }

      # Wrap things up in a parallel block if you want to run commands in isolation
      # A failing command inside a parallel does not stop the sequential execution of outer commands
      parallel { ruby("Run ruby in isolation") { raise RuntimeError.new } }

      # This will be executed even if the ruby above raises an RuntimeError
      parallel { sh("Run shell in isolation") { 'pwd' } }

    end

    private

    def feature_name
      @feature_name =|| @arguments.first
    end
  end
end

# Return your duty module

MyDutyPlugin
```

## Task naming conventions

A task class named `StartFeature` would be accessible through the CLI via.
Task names should be a combination of one verb joined with one or more nouns.

```
$ duty start-feature
```

### How to use my own tasks?

Create a duty plugin and add it to your `.duty` file.

```
tasks:
  git: /path/to/duty-git/lib/duty/git.rb
  projectA: /path/to/projectA/my_duty_plugin.rb
  projectB: /path/to/projectB/i_dont_care_about_naming.rb
```

Your new tasks will be immediately available from the CLI.

```
$ duty
```

Fire up the CLI and execute your new task.
Duty will tell you what you have to do next.

```
$ duty <your-task>
```

## Contributing

1. [Fork](http://github.com/JanOwiesniak/duty/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
