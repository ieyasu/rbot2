#!/usr/bin/php
<?
require_once("boilerplate.php");

if(strlen($args) < 1) {
	$args = $nick;
}

$nick = mysql_escape_string($args);

$a = db("select * from levels where nick like '$nick%' order by length(nick) limit 1");
if(strlen($a[0]['nick']) > 0)
	reply($a[0]['nick'] . ": " . $a[0]['level']);
else
	reply("$nick not found");


?>
