# Brewer
### A Ruby gem for [adaptiman/adaptibrew](http://github.com/adaptiman/adaptibrew)

# Disclaimer
This is a gem that will provide a command line interface for [adaptiman/adaptibrew](http://github.com/adaptiman/adaptibrew). It will provide pre-made procedures (see Brewer::Procedures) and an easy interface to control a brewing rig.

This will require an actual brew rig and all the equipment listed in [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew)'s readme. If you are looking to build an automated brew rig, **this is not the place to start**. Head over to [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew), or hit up [adaptiman](https://github.com/adaptiman).

# Quick Start

You should have ruby installed. Install this gem with:

```shell
gem install brewer
```

Start the brewer shell with

```shell
brewer
```


You can run the master procedure (the entire standard brewing process) with:

```ruby
>> procedures.master
```


You will be prompted to enter a slack `webhook_url`, which you can get from the `incoming-webhooks` integration on your slack channel.


You will be asked to load a recipe, or create a new one. These recipes store information like mash time, mash temperature, etc.

# Web Interface (in development)
[See here](http://github.com/llamicron/brewer-server)

# Installation
This is a gem, published on [rubygems.org](http://rubygems.org). Install it the recommended way with:
```shell
gem install brewer
```
This will be the latest stable release.
**Or** you can put the following line in a `Gemfile`:
```ruby
gem 'brewer'
```
or `.gemspec` file:
```ruby
spec.add_runtime_dependency 'brewer'
```

You may also download a .gem file from the [releases section on github](https://github.com/llamicron/brewer/releases) and install it that way, or further still build a new .gem file from the `brewer.gemspec` if you want the latest possible release. This is not recommended, as I do not regularly make releases on Github, just rubygems

After installation, run
```shell
brewer
```
to open an interactive shell to control your brew rig in realtime. Just like any other gem, you can `require 'brewer'` from another ruby project.

# Note
**Warning: RDoc may have a seizure when encountering Gemfiles, Rakefiles, etc. Basically files that don't end in `.rb` but have ruby syntax. Docs will be a bit weird on those files. I suggest just reading the comments in source.**
Documentation is in `doc/` or on rubygems.org

---
