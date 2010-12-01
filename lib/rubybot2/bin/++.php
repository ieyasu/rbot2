#!/usr/bin/php
<?
	require_once("boilerplate.php");
	if(strlen($arg[0]) == 0) reply_exit("Need something to modify!");
	$thing = mysql_escape_string($arg[0]);
	$data = db("select points from points where nick=\"$thing\"");
	if(isset($data[0]['points'])) {
		$newvalue = $data[0]['points'] + 1;
		db("update points set points=\"$newvalue\" where nick=\"$thing\"");
	}
	else {
		$newvalue = 1;
		db("insert into points (nick, points) values (\"$thing\", \"$newvalue\")");
	}
	db("delete from points where points=\"0\"");
	reply("$thing has $newvalue points");
?>
