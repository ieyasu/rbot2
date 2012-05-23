<?
	ini_set("html_errors", false);
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

	function reply($message) {
		global $dest;
		reply_to($message, $dest);
	}

	function reply_to($message, $dest, $is_action = false) {
		$message = wrap($message);
		$messages = preg_split("/[\r\n]/", $message);
		foreach($messages as $message) {
			$message = rtrim($message, "\r\n");
			if($message == "") continue;
			if($is_action) $message = "\001ACTION $message\001";
			print "PRIVMSG $dest :$message\n";
		}
	}

	function reply_action($message) {
		global $dest;
		reply_to($message, $dest, true);
	}

	function reply_private($message) {
		global $nick;
		reply_to($message, $nick);
	}

	function reply_exit($message) {
		reply($message);
		exit();
	}

	function wrap($message) {
		return wordwrap($message, 450, "\n", true);
	}
?>
