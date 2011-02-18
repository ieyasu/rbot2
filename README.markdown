rbot2
=====

This bot, rbot2, or as I usually refer to it, rubybot, is a wizened but capable IRC bot with many awesome features but much legacy. Despite the name, it is a polyglot of Ruby, PHP, Python and maybe some shell. It's a bit hairy, but if you find it useful, great!

Setup and Running
-----------------

To get started, you will need to:

* git clone git@github.com:ieyasu/rbot2.git
* install the sqlite3 libraryand -dev packages if applicable to your linux distro
  This is `apt-get install libsqlite3-dev` on debian and ubuntu.
* bundle install
* rake db:create
* cp run/config.rb.example run/config.rb and edit for your site
* cp start_rubybot.sh.example start_rubybot.sh and edit for your site
* ./start_rubybot.sh
* Connect to an IRC channel rbot2 is on and try a command, e.g. !thump

To see how to modify with the bot, read on.

Principles of Operation
-----------------------

Rubybot expects to be run from a location with a directory structure containing its configuration. I call this the 'run' directory, and an example run directory is included in the repository. You do not need to use that one, but it lets you run the bot out of the box.

The run/ configuration is involved:

* a db/ directory with the rubybot.db database file and symlinks to the data files in CLONE_ROOT/db/
* log/ for log files
* bin/ for normal bot commands
* commands/ for internal commands
* plugins/ for bot plugins - these give the bot its behavior
* boilerplate.* and other dep symlinks
* config.rb

The rubybot core (lib/rubybot2/rbot2.rb) loads the config file and plugins, then connects to the IRC server. Everything else is handled by the plugins. The plugins implement m_MESSAGE_NAME(msg, replier) methods for every IRC message they want to process. Their respone, if any, comes through the replier object. Look in lib/rubybot2/irc.rb and replier.rb for the IRC::Message and IRC::Replier classes.

The internal commands are found under lib/rubybot2/commands/. These files have classes with methods named after the pattern m_COMMAND_NAME which are called for matching command names. These commands are loaded into the main rubybot process to implement basic functionality, especially database-intensive things such as sending 'nexts' and account manipulation. If you are adding new commands, you should probably write a normal command instead of an internal one.

### 'Normal' Commands

The 'normal' commands are implemented as exec()able (#! line and exec bit) scripts in lib/rubybot2/bin/. Symlinks are then created in the run/bin/ directory with the command's un-suffixed name, and multiple symlinks can be made to create aliases, e.g. run/bin/tld and run/bin/country both point to lib/rubybot2/bin/tld.rb. When rubybot runs a normal command, the current working directory is the run directory. The arguments are: nick the message came from, the destination of the message (usually a channel), and the 'arguments' to the command (everything after the !command-name part). Additionally, the environment variable ZIP is set to the nick's location (if they have set it for their account) or the default defined in config.rb. The command is expected to reply with raw IRC protocol on stdout. For debugging purposes, stderr is captured and sent to the command's origin. To make command writing easier, boilerplate.{rb,php,py} have been written. See lib/rubybot2/bin/example.rb for a basic boilerplate.rb-based command.

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
