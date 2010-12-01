#!/usr/bin/php
<?
	require_once("boilerplate.php");
	if(strlen($args) < 1) reply_exit("rot13 something");
	reply(str_rot13($args));
?>
