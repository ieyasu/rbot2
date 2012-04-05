#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$file = file_get_contents("http://www.dailyhaiku.org/");
	preg_match_all("/<p class=\"haiku\">(.*?)<\/p>/is", $file, $matches);
	$text = strip_tags($matches[1][0]);
	$text = trim($text);
	$text = str_replace("\r", "", $text);
	$text = str_replace("\n", " / ", $text);
	$text = str_replace("&nbsp;", " ", $text);
	$text = str_replace("&mdash;", "--", $text);
	$text = html_entity_decode($text);
	$text = preg_replace("/\s+/", " ", $text);
	reply($text);
?>
