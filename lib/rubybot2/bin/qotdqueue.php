#!/usr/bin/php
<?
	$query = "select count(1) as c from rash_submit";
	require_once("boilerplate.php");
	mysql_select_db("quotes");
	$data = db($query);
	$data = $data[0]['c'];
	reply("$data items in queue");
?>
