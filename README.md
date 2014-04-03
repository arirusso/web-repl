# web-repl
    
This is a Javascript [REPL](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) that runs in Ruby.  Evaluation is done by a web browser instance.

One use of this is to use the Chrome Developer Console remotely.

I was working on a toy program recently that needed the browser to be in full screen mode, which made using the regular Chrome console very difficult to use.  I came up with this program as an alternative.

There are similar tools that run in nodejs for example but since my program uses a Ruby backend anyway, this is convenient for me.

It communicates over websocket.

There is basically no attention to security here, so please use at your own discretion.  

#### Installation

    gem install web-repl
    
or with Bundler

    gem "web-repl"

#### License

Licensed under Apache 2.0, See the file LICENSE
Copyright (c) 2014 [Ari Russo](http://arirusso.com) 
