#!/usr/bin/php
<?
	require_once("boilerplate.php");
	if(strlen($args) < 1) reply_exit("Give me an MD5 string and I'll try to reverse it");
	try {
		@$result = file_get_contents('http://www.md5decrypter.co.uk/feed/api.aspx?' . urlencode($args));
	} catch (Exception $e) {
		reply_exit("Not found");
	}
	$xml = new SimpleXMLElement($result);
	$result = $xml->hash->text;
	if($result == "") reply_exit("Not found");
	reply_exit($result);
?>
