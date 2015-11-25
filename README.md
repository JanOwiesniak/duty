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

## Add shell completion

This gem supports a simple shell completion for
[Bash](https://www.gnu.org/software/bash/) and [ZSH](http://www.zsh.org).
To enable this feature load the completion functions:

```
source duty.completion
```

## Usage

```
duty <task> [<args>]
```

## Naming conventions

Task names should be a combination of one verb joined with one or more nouns.

Examples:

* `start-feature`
* `continue-feature`

## Extend duty with your own tasks

* Create a new `tasks` dir
* Create one or more duty task files in there
* Create a .duty file e.g. in your home dir

### How does a basic duty task looks like?

path/to/your/new/tasks/my_new_task.rb

```ruby
require 'duty/tasks/base'

module Duty
  module Tasks
    class MyNewTask < Duty::Tasks::Base
    end
  end
end
```

### How does a .duty file looks like?

.duty

```
tasks:
  git: /path/to/my/git/specific/tasks
  projectA: /path/to/my/projectA/specific/tasks
  projectB: /path/to/my/projectB/specific/tasks
```

### How to use my own task?

Your new task will be immediately available from the CLI.

```
duty
```

Fire up the CLI and execute your new task.
Duty will tell you what you have to do next.

```
duty <your-task>
```

## Contributing

1. [Fork](http://github.com/JanOwiesniak/duty/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
