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
duty
```

## Create new command

* Create a new class in the `Duty::Commands` namespace
* Put it into `lib/duty/commands/<your_command>.rb`
* Require it from `lib/duty/commands.rb`

Your new command will be immediately available from the CLI

```
duty <your-command>
```

### Example

#### FooBar command

`lib/duty/commands/foo_bar.rb`

```
module Duty
  module Commands
    class FooBar < Duty::Commands::Base
    end
  end
end
```

#### CLI

Fire up the CLI and execute your new command.
Duty will tell you what you have to do next.

```
duty <your-command>
```

## Available commands

### New feature

* It checks out the `master` branch.
* It creates a new feature branch called `feature/<name>`.
* It switches to the new feature branch.
* It sets the upstream to `origin/feature/<name>`.
* It pushs the new feature branch to origin.

```
duty new-feature <name>
```
