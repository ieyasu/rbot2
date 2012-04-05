#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$page = mt_rand(1, 60);
	$file = file_get_contents("http://itmademyday.com/page/$page/");
	if(!preg_match_all("/<blockquote>.*?<\\/blockquote>/i", $file, $matches)) reply_die("No regex match");
	$data = $matches[0];
	$data = $data[mt_rand(0, sizeof($data)-1)];
	$data = strip_tags($data);
	$data = html_entity_decode($data, ENT_QUOTES, "UTF-8");
	$data = iconv("UTF-8", "ASCII//TRANSLIT", $data); 
	reply($data);
?>
