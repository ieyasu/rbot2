<?
	if(strlen($args) == 0) {
		print stripslashes("pong: $source $dest");
		exit();
	}
	$args = stripslashes($args);
	$sargs = escapeshellarg($args);
	$result = `ping -c 1 -o -Q $sargs | grep "bytes from"`;
	if(strlen($result) == 0) {
		print "ping: No reply from $args";
		exit();
	}
	print "ping: $result";
?>
