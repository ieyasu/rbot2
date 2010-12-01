#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$file = file_get_contents("http://www.randomjoke.com/topic/oneliners.php");
	if(!preg_match("/([^>]+)<CENTER>/", $file, $matches)) reply_exit("No regex match");
	reply(trim($matches[1]));
?>
