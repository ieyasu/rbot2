#!/usr/bin/php
<?
require_once("boilerplate.php");

if(strlen($args) < 1) {
	reply_exit("Need a level");
}

$fullnick = mysql_escape_string($nick);
$nick = strtolower(substr($fullnick, 0, 3));
$level = $args;

db("delete from levels where nick like '$nick%'");
db("insert into levels(nick, level) values ('$fullnick', '$level');");

reply("ok");


?>
