#!/usr/bin/php
<?
	require_once("boilerplate.php");
	if(strlen($args) < 1) reply_exit("Give me an MD5 string and I'll try to reverse it");
	try {
		@$result = file_get_contents('http://www.md5decrypter.co.uk/feed/api.aspx?' . urlencode($args));
		if($result == "") reply_exit("Error: 50-hash daily limit reached?");
		$xml = new SimpleXMLElement($result);
		$result = $xml->hash->text;
		if($result == "") reply_exit("Not found");
		reply_exit($result);
	} catch (Exception $e) {
		reply_exit("Not found: $e");
	}
?>
