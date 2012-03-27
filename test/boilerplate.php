<?
	// todo: this is copied straight out of ../boilerplate.php
	ini_set("html_errors", false);
	require_once("../db.php");
	// nick, dest, args
	global $nick;
	$nick = $argv[1];
	global $orig_dest;
	$orig_dest = $argv[2];
	if($orig_dest{0} != '#' && $orig_dest{0} != '&') $dest = $nick;
	else $dest = $orig_dest;
	global $args;
	$args = $argv[3];
	global $arg; // args split by space
	$arg = preg_split("/\s+/", $args);

	// We don't want to put all the irc formatting around messages for testing.
	function reply($message) {
		//print "reply called with $message\n";
		print($message);
	}
	function reply_exit($message) {
		reply($message);
		// Since we want to exit the class being run but not the test, we throw
		// an exception and catch it in run().
		//throw new Exception("exited");
		exit();
	}
?>
