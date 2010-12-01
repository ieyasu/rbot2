#!/usr/bin/php
<?
	require_once("boilerplate.php");
	if($args == "") reply_exit("urlencode something");
	reply(urlencode($args));
?>
