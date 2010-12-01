#!/usr/bin/php
<?
	require_once("boilerplate.php");
	mysql_select_db("quotes");
	$ret = array();
	$count = "";
	// If there are no args, it's a random quote
	if(strlen($args) == 0) {
		$ret = db("select * from rash_quotes order by rand() limit 1");
		$ret = $ret[0];
	} else {
		$args = htmlspecialchars($args);
		$args = mysql_escape_string($args);
		if(!isset($arg[1])) {
			// If there's one arg, it could be either an id or a search string, try id first
			$ret = db("select * from rash_quotes where id='$args'");
			$ret = $ret[0];
		}
		if(!isset($ret['id'])) {
			// now we know args is a search string, so we can get the count
			$count = db("select count(1) as c from rash_quotes where quote rlike '$args'");
			if(!is_array($count)) reply_exit("Regex error: $count");
			$count = $count[0]['c'];
			if($count != 0) {
				$ret = db("select * from rash_quotes where quote rlike '$args' order by rand() limit 1");
				$ret = $ret[0];
			}
		}
	}
	if(!isset($ret['id'])) reply_exit("No quote found");
	$id = $ret['id'];
	$rating = $ret['rating'];
	$quote = html_entity_decode($ret['quote']);
	$quote = join(" || ", preg_split("/[\r\n]+/", $quote));
	if($count) reply_exit("($count found) #$id [$rating] $quote");
	reply("#$id [$rating] $quote");
?>
  
