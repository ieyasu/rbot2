#!/usr/bin/php
<?
	require_once("boilerplate.php");

	$data = file_get_contents("http://feeds.feedburner.com/Kanji-a-dayLevel1?format=xml");
	$xml = new SimpleXMLElement($data);
//	print_r($xml->channel->item);
	$kanji = $xml->channel->item->title;
	$description = $xml->channel->item->description;
	$description = strip_tags($description);
	$description = str_replace(" readings", "", $description);
	$description = str_replace("meaning", " meaning", $description);
	$description = str_replace("  ", " ", $description);
	reply("kanji of the day: $kanji $description");
?>
