#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$args = trim($args);
	if($args == "") reply_exit("factor a number");
	if($args[0] == "-") reply_exit("factor a number");
	$args = escapeshellarg($args);
	reply(trim(shell_exec("factor $args 2>&1")));
?>
