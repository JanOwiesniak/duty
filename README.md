[![Build Status](https://travis-ci.org/JanOwiesniak/duty.svg?branch=master)](https://travis-ci.org/JanOwiesniak/duty) [![Inline docs](http://inch-ci.org/github/JanOwiesniak/duty.svg?branch=master)](http://inch-ci.org/github/JanOwiesniak/duty)

# Duty

Craft.
Don't battle.
Do your duty, let me handle the rest.

## Install

```
not published on rubygems.org yet
```

## Add executable to your $PATH

```
export PATH="$PATH:$HOME/path/to/duty/bin"
```

## Usage

```
duty <task> [<args>]
```

## Core tasks

We already implemented some common use cases you might want to use.
You get a list of all available tasks by typing:

```
duty
```

### Create new feature

* It checks out the `master` branch.
* It creates a new feature branch called `feature/<name>`.
* It switches to the new feature branch.
* It sets the upstream to `origin/feature/<name>`.
* It pushs the new feature branch to origin.

```
duty new-feature <name>
```

## Extend duty with your own tasks

* Create a new `tasks` dir
* Create one or more duty command files in there
* Create a .duty file e.g. in your home dir

### How does a basic duty command looks like?

path/to/your/new/tasks/my_new_command.rb

```ruby
require 'duty/tasks/base'

module Duty
  module Tasks
    class MyNewCommand < Duty::Tasks::Base
    end
  end
end
```

### How does a .duty file looks like?

.duty

```
tasks: /path/to/my/project/specific/tasks
```

### How to use my own command?

Your new command will be immediately available from the CLI.

```
duty
```

Fire up the CLI and execute your new command.
Duty will tell you what you have to do next.

```
duty <your-command>
```
