#!/usr/bin/php
<?
	require_once("boilerplate.php");
	reply("nick is '$nick', dest is '$dest', orig-dest is '{$orig_dest}', args is '$args'\nThis is line two of a reply");
	reply_action("this is an action");
	reply_private("this is a private reply");
	print "This is standard out\n";
	fwrite(STDERR, "This is to standard err\n");
?>
