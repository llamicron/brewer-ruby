# Brewer
### A Ruby gem for [adaptiman/adaptibrew](http://github.com/adaptiman/adaptibrew)

# Disclaimer
This is just a gem to make adaptibrew more user friendly. It will provide a clean shell and easy to understand methods for all the actions you need to control your brew rig with continuity.

This will require an actual brew rig and all the equipment listed in [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew)'s readme. If you are looking to build an automated brew rig, **this is not the place to start**. Head over to [adaptiman/adaptibrew](https://github.com/adaptiman/adaptibrew), or hit up [adaptiman](https://github.com/adaptiman).

# Installation
This is a gem, published on [rubygems.org](http://rubygems.org). Install it the recommended way with:
```shell
gem install brewer
```
This will be the latest stable release.
**Or** you can put the following line in a `Gemfile`;
```ruby
gem 'brewer'
```
and run `bundle install`.

You may also download a .gem file from the releases section and install it that way, or further still build a new .gem file from the `brewer.gemspec` if you want the latest possible release. Keep in mind this may not be stable.

After installation, run
```shell
brewer
```
to open an interactive shell to control your brew rig in realtime.Just like any other gem, you can `require 'brewer'` from another ruby project.

# Documentation
**Warning: RDoc may have a seizure when encountering Gemfiles, Rakefiles, etc. Basically files that don't end in `.rb` but have ruby syntax. Docs will be a bit weird on those files. I suggest just reading the comments in source.**
Documentation is in `doc/` or on rubygems.org

---

*This line is for CI build triggers, please ignore*
