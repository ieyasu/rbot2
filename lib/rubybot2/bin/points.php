#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$args = mysql_escape_string(strtolower($args));
	$source = mysql_escape_string(strtolower($source));
	if($args == "") {
		$top = db("select * from points order by points+0 desc limit 1");
		$bot = db("select * from points order by points+0 asc limit 1");
		$top = $top[0]['nick'] . " has " . $top[0]['points'] . " points";
		$bot = $bot[0]['nick'] . " has " . $bot[0]['points'] . " points";
		reply("Usage: !points <thing>; best: $top, worst: $bot");
	} else {
		$points = get_points($args);
		reply("$args has $points points\n");
	}
	function get_points($nick) {
		$a = db("select * from points where nick=\"$nick\"");
		if(isset($a[0]['points'])) return $a[0]['points'];
		return 0;
	}
?>
