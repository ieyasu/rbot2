#!/usr/bin/php
<?
	require_once("boilerplate.php");
	require_once("php-helpers/timetill.php");
	reply_exit(timeTill(time(), $args));
?>
