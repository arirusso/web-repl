# web-repl
    
This is a Javascript [REPL](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) that runs in Ruby.  Evaluation is done by a web browser instance.

One use of this is to control the Chrome Developer Console remotely as such:

#### Background

I've been working on a toy project recently that requires browser content to be in fullscreen.  This makes live coding using the regular Chrome JS console more or less impossible.  Web-repl is what I came up with as an alternative.

There are similar tools that run in nodejs and other languages but this is convenient for me because my project uses a Ruby backend anyway.

Server/client interaction uses JSON over Websocket. There's no extra attention to security here other than what is implicit in Websockets, so please use at your own discretion.  

#### Usage

###### Browser

To enable the browser side of this, include something like this in the head of your webpage:

```html
<script src="js/replConnection.js"></script>
<script type="text/javascript">
  window.onload = function() {
    var repl = new ReplConnection("localhost", 9007, { debug: true, reconnect: true });
    repl.start();
  }
</script>
```

The javascript assets for this project are located in the [/js directory](https://github.com/arirusso/web-repl/tree/master/js).

There is also a full example of a webpage (with [rack](http://rack.github.io/) configuration) in the [/examples/page directory](https://github.com/arirusso/web-repl/tree/master/examples/page)

###### REPL

The REPL can be used either in a Ruby program/console or there is a "binary" Ruby script.

In Ruby the usage looks like this:

```ruby
require "web-repl"

WebRepl.start(:host => "localhost", :port => 9007)
```

You can see an explanation of background usage here.

To use this as a script, run this from the command line.  (The script should install with the gem)

    web-repl localhost:9007
    
#### Installation

    gem install web-repl
    
or with Bundler

    gem "web-repl"

#### License

Licensed under Apache 2.0, See the file LICENSE
Copyright (c) 2014 [Ari Russo](http://arirusso.com) 

