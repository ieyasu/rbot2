rbot2
=====

This bot, rbot2, or as I usually refer to it, rubybot, is a wizened but capable IRC bot with many awesome features but much legacy. Despite the name, it is a polyglot of Ruby, PHP, Python and maybe some shell. It's a bit hairy, but if you find it useful, great!

Setup and Running
-----------------

To get started, you will need to:

* git clone git@github.com:ieyasu/rbot2.git
* install the sqlite3 library and -dev packages if applicable to your linux distro
  This is `apt-get install libsqlite3-dev` on debian and ubuntu.
* bundle install
* rake db:create
* cp config.rb.example config.rb and edit for your site
* cp bin/ENVIRONMENT.example bin/ENVIRONMENT
* look over bin/ENVIRONMENT to see if you need to change anything
* bin/start_rubybot
* Connect to an IRC channel rbot2 is on and try a command, e.g. !thump

To see how to modify with the bot, read on.

Principles of Operation
-----------------------

Rubybot is run from the root of the source tree.  There are several important files and directories:

* a db/ directory with the rubybot.db main database file.
* log/ for log files.
* hooks/ for normal bot commands.
* services/ - these run as child processes of the main process and decide what to do with a given IRC message.
* config.rb - tells the bot which server to connect to, which channels to join, and many other aspects of internal behavior.

The rubybot main process (bin/rubybot.rb) loads the config file, starts the services, then connects to the IRC server and processes messages.  Everything beyond basic connection is handled by the services.  They register for the IRC messages they wish to process, e.g. PRIVMSG.  The matching messages are written to their STDIN, and anything written to their STDOUT is relayed to the IRC server.  All communication is done as IRC protocol messages.

The internal commands are found under commands/.  They are slated for a rewrite to normal 'hook' commands, so this is all I will say about them.


### 'Hook' Commands

These are implemented by the comman_runner.rb service.  The hooks are exec()able scripts or compiled programs in the hooks/ directory.  The hook's file name is the same as the command name, so command aliases are created by symlinking to the original hook file.

The basic hook interface: the nick, channel and text of the originating PRIVMSG are passed as three command line arguments.  If it is a private message, the 'channel' will actually be the bot's nick.  Also, the environment variable ZIP is set according to either the nick's account or the default zip in config.rb.  The hook is then to respond with zero or more newline-terminated messages in IRC protocol.  For debugging purposes, stderr is captured and sent to the command's origin.

To make command writing easier, boilerplate.{rb,php,py} have been written.  These are kind of ugly, so a more streamlined approach is in development.  If a hook file has a recognized language-specific extension, a special hook running script is used to provide a nicer API to get the job done with less code than with the boilerplate approach.


### Accounts

Rubybot has accounts which allow personalized location and other information. For more on accounts, see the ACCOUNTS.markdown file.

How to Contribute
-----------------

Is your git-fu lacking? Here's some helpful hints:

* Install git
* Create a github account
* Create an ssh pubkey if you don't have one
* Add your ssh pubkey to your github account
* Get bishop to add your github account as a contributor to the project
* You are now an official rbot2 ninja

The Rubybot Story
-----------------

A long time ago on an IRC server far, far away my friends and I inhabited a channel #linux. There was a bot called DarkHelmet which took care of our botly needs. One day, one of these friends said to himself, "I need more gizmos in my IRC!" and thus supplebot was born.

The supplebot was indeed a supple bot and treated us well--for a time. Many awesome commands were written, but you see, supplebot was written in PHP. 'The little web language that could' had some memory collection issues on long-running processes. 600 megabyte IRC bots would not stand.

Another friend saw this, and thought he could do better. "In C", he said, "that would never happen!" His creation was known as Cbot. It solved the resource usage issue, and was pretty sweet. It understood supplebot's commands, and even more commands were written--some even in C. Unfortunately, Cbot needed to be recompiled for each new command which was troublesome since its maintainer was not always around.

About this time (spring 2002 IIRC) I had been starting to learn ruby. A friend had come to me with, "OMG, you must check out this language fresh out of Japan. It's like Perl, but even better!" This was no small thing. The Pragmatic Programmers were just learning Ruby themselves. Rails wasn't even a glimmer in DHH's eye. Gems sure didn't exist. Worst of all, the VM wasn't especially stable, especially on FreeBSD. The last one would bite me later.

Anyway, to return to our saga, I saw Cbot's problems and decided that writing an IRC bot would be an excellent way to learn Ruby. I would fix all the problems from previous bots and add zillions of exciting new features! So many ideas and so much enthusiasm. So away I programmed, and after a few weeks I had a bot good enough to replace Cbot. It did not need to be recompiled, and it seemed to work pretty well. This was rubybot 1.

After a while though, it began crashing. IO class avoiding native code extensions were written. Watchdog scripts were employed. Reconnect code implemented. The whole hackish mess worked well enough, but there was grumbling. Fortunately for rubybot, no one did more than grumble because by this time we were growing up, getting jobs and had Real Work to do.

Still, after a few years of hacks, the discovery of ruby by more of the programming world, fixes to MRI and my own increased understanding of Ruby, I thought I could do better. So I wrote version 2. This is the version we have now.

There were some bad years where I got burnt out on programming (start-ups and I do not do well together) and didn't really maintain it. There was much wailing and gnashing of teeth. Of course, still no one else was motivated enough to replace the bot, so it remained. After a while I made my peace with programming and began more actively maintaining the bot. Friends convinced me to get the code onto github and start using the latest and greatest Ruby tools like Rake and Bundler. It still needs tests. I am slowly getting everything up to speed so that others can run the bot on their IRC servers and even contribute.
