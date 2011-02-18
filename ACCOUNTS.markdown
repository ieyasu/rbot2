Rubybot User Account Guide
==========================

Ruby bot provides user accounts and preferences to provide advanced features in IRC services.  An account is good for preventing others from stealing your nexts (due to nick pattern collision) and setting your default location for weather information and the like.

Accounts and Authentication
---------------------------

To create a new ruby bot account, type

    <code>/msg rb register &lt;account-name&gt; &lt;password&gt;</code>

at the command prompt. This creates a new account with the given name and indicated password. The account name must be alphanumeric and no more than 40 characters long. The password must be at least 6 characters long.

To destroy an account, type

    <code>/msg rb unregister &lt;account-name&gt; &lt;password&gt;</code>

at the command prompt. This will remove all traces of your account including archived nexts, so be sure you mean to do this.

To add a nick to an account, type
    <code>/msg rb addnick &lt;account-name&gt; &lt;password&gt;</code>

at the command prompt. This adds your current nick name to the indicated account. You cannot add a nick to an account until the account is created with the <code>register</code> command.

To remove a nick from an account, use the

    <code>/msg rb delnick &lt;account-name&gt; &lt;password&gt;</code>

command. This removes the given nick from the indicated account.

To list the accounts in the system, type

    <code>!accounts</code>

at the command prompt. This prints the accounts registered to the system.

To list the nicks belonging to an account, use the

    <code>!nicks &lt;account-name&gt;</code>

command. This prints the nicks belonging to the given account.

To authenticate your current nick, use

    <code>/msg rb login &lt;account-name&gt; &lt;password&gt;</code>

Ruby bot will check the given password against the password for the account. If everything hashes correctly, You will be authenticated.

To log out of your account, type

    <code>/msg rb logout</code>

at the command prompt.  You must login before receiving nexts sent to your account.

To set your zip location, type

    <code>/msg rb setzip &lt;zip&gt; </code>

at the command prompt.  You must be logged in before running this command.  Once set, rubybot will use this zip location as the default location for weather information and other local-specific data returned.

To change your password, use

    <code>/msg rb setpass &lt;old-pass&gt; &lt;new-pass&gt;</code>

You must be authenticated first.  If everything checks out, your password will be updated to the new value.


Next Management
---------------

If you are logged in to your account, you can look at nexts which you sent but have not been delivered to their recipients yet, delete the last next you send, or past nexts you have received.

To list your undelivered nexts, use

    <code>!listnexts</code>

This will produce

  <code>0. nick1: 'first message', 1. nick2: 'second longer mess...'</code>

The number in front of each message is used by the deletenext command.

To delete the most recent undelivered nexts, use the command

    <code>!deletelastnext</code>

The most recent next corresponds with the index 0 from !listnexts.

To view nexts you received before, use

    <code>!pastnexts <i>[</i>&lt;count back&gt; <i>[</i>&lt;max to list&gt;<i>]]</i></code>

Where &lt;count back&gt; is the number of messages to skip starting with the more recent nexts; and &lt;max to list&gt; is the maximum number of past nexts to display.
