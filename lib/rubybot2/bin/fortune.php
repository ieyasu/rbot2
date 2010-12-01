#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$cmd = "-a";
	if($args) $cmd = escapeshellarg($args);
	$max_lines = 3;
	$c = 0;
	do {
		$c++;
		if($c > 100) {
			print "No fortunes found\n";
			exit;
		}
		$fortune = `/usr/games/fortune $cmd 2>&1`;
		$lines = split("\n", $fortune);
	} while(count($lines) > $max_lines + 1);
	$fortune = str_replace("\t", "    ", $fortune);
	reply($fortune);
?>
