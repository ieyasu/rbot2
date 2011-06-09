Rubybot User Account Guide
==========================

Ruby bot provides user accounts and preferences to provide advanced features in IRC services.  An account is good for preventing others from stealing your nexts (due to nick pattern collision) and setting your default location for weather information and the like.

Accounts
--------

To create a new ruby bot account, type

    /msg rb register <account-name> <password>

at the command prompt. This creates a new account with the given name and indicated password. The account name must be alphanumeric and no more than 40 characters long. The password must be at least 6 characters long.

To destroy an account, type

    /msg rb unregister <account-name> <password>

at the command prompt. This will remove all traces of your account including archived nexts, so be sure you mean to do this.

To add a nick to an account, type

    /msg rb addnick <account-name> <password>

at the command prompt. This adds your current nick name to the indicated account. You cannot add a nick to an account until the account is created with the `register` command.

To remove a nick from an account, use the

    /msg rb delnick <account-name> <password>

command. This removes the given nick from the indicated account.

To list the accounts in the system, type

    !accounts

at the command prompt. This prints the accounts registered to the system.

To list the nicks belonging to an account, use the

    !nicks <account-name>

command. This prints the nicks belonging to the given account.

To set your zip location, type

    /msg rb setzip <zip> <password>

at the command prompt.  Once set, rubybot will use this zip location as the default location for weather information and other local-specific data returned.

To change your password, use

    /msg rb setpass <old-pass> <new-pass>

If everything checks out, your password will be updated to the new value.


Next Management
---------------

If you are logged in to your account, you can look at nexts which you sent but have not been delivered to their recipients yet, delete the last next you send, or past nexts you have received.

To list your undelivered nexts, use

    !listnexts

This will produce

  0. nick1: 'first message', 1. nick2: 'second longer mess...'

The number in front of each message is used by the deletenext command.

To delete the most recent undelivered nexts, use the command

    !deletelastnext

The most recent next corresponds with the index 0 from !listnexts.

To view nexts you received before, use

    !pastnexts [<count back> [<max to list>]]

Where <count back> is the number of messages to skip starting with the more recent nexts; and <max to list> is the maximum number of past nexts to display.
