#!/usr/bin/php
<?
	require_once("boilerplate.php");
	mysql_select_db("quotes");
	if(!is_numeric($args)) reply_exit("Need a valid ID");
	$data = db("select * from rash_quotes where id=\"$args\"");
	if(!isset($data[0])) reply_exit("Need a valid ID");
	$score = $data[0]['rating'];
	$score--;
	db("update rash_quotes set rating=$score where id=\"$args\"");
	reply("quote $args has $score points");
?>
