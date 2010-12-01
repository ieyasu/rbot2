<?
require('inc/cbotdb.inc');
/*
| nick     | text | YES  |     | NULL    |       |
| keyval   | text | YES  |     | NULL    |       |
| assocval | text | YES  |     | NULL    |       |
*/

if ($args) {
	$a = mqns("select * from whatis where lcase(keyval) = lcase('$args') limit 1");
	if (!$a) {
		print "i don't know about " . $args . "\n";
		exit;
	} else {
		@mqns("delete from whatis where lcase(keyval) = lcase('$args')");
		print "ok\n";
	}
}

?>
