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

### Create new feature

* It checks out the `master` branch.
* It creates a new feature branch called `feature/<name>`.
* It switches to the new feature branch.
* It sets the upstream to `origin/feature/<name>`.
* It pushs the new feature branch to origin.

```
duty new-feature <name>
```
