# How to figure all this shit out
Look in `bin/brewer-server` for a sinatra server. You don't have to know how any of it works, but take a look at the routes near the bottom.

## Routes
There's a comment ("# Routes") marking the beginning of the routes in `bin/brewer-server`. Here's an example:

```ruby
get '/' do
  @relays_status = $brewer.relays_status
  @pid_status = @brewer.pid

  erb :index
end
```

This will listen for a `get` request on `/`. When it finds one, it will get some data from the brew rig using my gem. The last line, `erb :index`, says to serve a `.erb` file named `index.erb`. All the `.erb` files are in `/views`.

## [ERB](http://www.stuartellis.name/articles/erb/)
ERB is embedded ruby. Super simple, just regular html/css/js, but you can do shit like:

```
<%= @pid_status %>
```

to print the `@pid_status` variable that we created in the `/` route. It's essentially the same as `<?php ?>` tags.

## Where you come in
The front end looks meh, but try resizing the window and you will see the depths of technical debt I have dug into with my lazy html. I don't care if you completely restart from scratch or fix what I have, it's up to you. You could also leave it how it is if you want. What I really need is some AJAX style stuff (idk what i'm talking about) to update the info that's on the `index` page. Basically I just need to call a few lines on ruby without refreshing the page. I don't know how you would accomplish that, but I can setup whatever you need.

The 2 lines being called in the route above:
```ruby
@relays_status = $brewer.relays_status
@pid_status = @brewer.pid
```
will update those variables with live data from the hardware. We may need to setup a new route, something like:
```ruby
get '/update-pid-status' do
  @pid_status = @brewer.pid
end
```
that you could somehow call with js. I don't really know how this works though, so that could be completely wrong. I've made this branch (`jakeg`) that you can have, and you can fork this repo so you can do pull requests and shit.

## Running the server
The `bin/brewer-server` file is a ruby file without the extension. You can just run it. Example:
```shell
$ pwd
/home/pi/brewer/
$ bin/brewer-server

sinatra server stuff...

OR

$ pwd
/some/god/forsaken/directory/
$ /home/pi/brewer/bin/brewer-server

sinatra server stuff...


```

This will start a server on port `4567` by default. You can specify a port with `bin/brewer-server -p PORT_NUMBER`. Anything under port 1024 will need sudo, though. Note: when the gem is installed as it would be in production, the `bin/brewer` and `bin/brewer-server` executables are added to your path, so you can call `brewer-server` regardless of what directory you are in. This is just for development.

## Git
This is kind of tricky because all the development has to happen on the same machine. What I would do is fork the repo, and clone your fork and work from there. We could have `brewer`, and `jakes-brewer` for instance. That way we won't get in each others way.
