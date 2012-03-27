#!/usr/bin/php
<?
	require_once("boilerplate.php");
	require_once("inc/timetill.php");
	reply_exit(timeTill(time(), $args));
?>
