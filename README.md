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


You can now run the master procedure (the entire standard brewing process) with:

```ruby
>> procedures.master
```


You will be prompted to enter a slack `webhook_url`, which you can get from the `incoming-webhooks` integration on your slack channel.


The shell will ask you for recipe variables in the beginning, and will warn you when you need to intervene.

# Web Interface (in development)
Run the `brewer-server` binary the same way you would run the `brewer` binary. This will start a `sinatra` server on your pi's ip address. The default port is `8080`, but you can specify a custom port with:

```shell
sudo brewer-server -p YOUR_PORT
```

Keep in mind that any port below 1024 will need root access. I like to specify port `80` (http default) so that I can leave the port off and it will default to 80.

You can add a line to `/etc/hosts` on your workstation and redirect a url to your pi's ip. For instance, the relevant line in my `/etc/hosts` looks like this:

```shell
192.168.0.224   navasota.brew
```

so I can visit `navasota.brew` and see the brewing homepage when `brewer-server` is running.

# Starting the server on system startup

You may want to start the `brewer-server` an system boot so that a workstation is not required to connect (ssh) to your pi.

[See here for a StackOverflow solution](https://raspberrypi.stackexchange.com/a/8735) or read on below.

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
s.add_runtime_dependency 'brewer'
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

*This line is for CI build triggers, please ignore*
