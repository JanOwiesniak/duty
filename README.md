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
duty <command> [<args>]
```

## Core commands

We already implemented some common use cases you might want to use.
You get a list of all available commands by typing:

```
duty
```

## Naming conventions

Task names should be a combination of one verb joined with one or more nouns.

Examples:

* `start-feature`
* `continue-feature`
* `create-pull-request`
* `accept-pull-request`
* `reject-pull-request`

### Start a new feature

* It checks out the `master` branch.
* It creates a new feature branch called `feature/<name>`.
* It switches to the new feature branch.
* It sets the upstream to `origin/feature/<name>`.
* It pushs the new feature branch to origin.

```
duty start-feature <name>
```

## Extend duty with your own commands

* Create a new `commands` dir
* Create one or more duty command files in there
* Create a .duty file e.g. in your home dir

### How does a basic duty command looks like?

path/to/your/new/commands/my_new_command.rb

```ruby
require 'duty/commands/base'

module Duty
  module Commands
    class MyNewCommand < Duty::Commands::Base
    end
  end
end
```

### How does a .duty file looks like?

.duty

```
commands: /path/to/my/project/specific/commands
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

## Contributing

1. [Fork](http://github.com/JanOwiesniak/duty/fork)
2. Add executable to your $PATH
3. Create new feature branch (`duty start-feature <my-awesome-feature>`)
4. Create new pull request
