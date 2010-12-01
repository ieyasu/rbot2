<?
	require_once("inc/ircdb.inc");

	$args = strtoupper($args);

	if(strlen($args) > 12) {
		print "$args: too long";
		exit;
	}

	$args = mysql_escape_string($args);
	$a = mqns("select word from scrabblewords where word = \"$args\"");
	if($a) print "$args is valid";
	else print "$args: not valid";
?>
