<?
require('inc/cbotdb.inc');
/*
| nick     | text | YES  |     | NULL    |       |
| keyval   | text | YES  |     | NULL    |       |
| assocval | text | YES  |     | NULL    |       |
*/

define(MULTILINE_ENABLE,false); // turn this off if it gets abused -- turned off 8/17/05 by sargon, there's no way to escape a \n!
define(SPAM_LIMIT,3); // number of lines allowed before sending as a privmsg instead of public
define(MAX_LIMIT,4); // max number of lines allowed, period.
define(MATCHES_LIMIT,3); // # of additional matches to display

if ($args) {
	// original query
	// $a = mqns("select * from whatis where keyval rlike '$args' limit 1");
	// this duplicates the query in whatis.c, from rb
	$args = stripslashes($args);
	$margs = mysql_escape_string($args);
	$a = mqns("select * from whatis where keyval regexp '$margs' order by length(keyval), keyval");
	if (!$a) {
		$append='';
		$more='';
		$errmsg = mysql_error();
		if(stristr($errmsg,'regex')) {
			$err = explode("'",$errmsg);
			$append = " (regex error: ".$err[1].")";
		}
		print "i don't know about $args$append\n";
	} else {
		$val = $a[0][assocval];
		if(count($a) > 1) {
			$atemp = $a;
			array_shift($atemp);
			$more_matches = array_chunk($atemp,MATCHES_LIMIT);
			$more_matches = $more_matches[0]; // first chunk
//			array_shift($more_matches);
			foreach($more_matches as $mm) {
				$match_names[] = $mm['keyval'];
			}
			$more = '"' . implode('", "',$match_names) . '"';
		}
		$prepend = '';
		if(MULTILINE_ENABLE) { 
			$prepend = (count(explode('\n',$val)) > SPAM_LIMIT ? '*' : '');
			// replace up to MAX_LIMIT lines.
			$val = implode("\n$prepend",explode('\n',$val,MAX_LIMIT));
		}
		$append = (count($a) > 1)?" (out of ".count($a)." matches, including $more)":'';
		print $prepend . $a[0][nick] . " taught me that " . 
			$a[0][keyval] . " is: $val$append\n";
//			print_r($a);
	}
}
else {
	print "proper usage: !whatis <regex>\n";
}

?>
