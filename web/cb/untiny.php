<?
	if(!$args) die("Reveal a tinyurl's true destination");
	//if(!strstr($args, "tinyurl.com")) die("Need a tinyurl");
	$args = escapeshellarg($args);
	$res = `wget -O /dev/null $args 2>&1 | grep "Location"`;
	$res = explode("\n", trim($res));
	$l = $res[0];

	if(!$l) die("Not found");
	if(!preg_match("/^Location: (.*) \[following\]$/", $l, $matches)) {
		die("not found");
	}
	print "Untinied: {$matches[1]}";
?>

