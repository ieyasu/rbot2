<?
require('inc/cbotdb.inc');
/*
| nick     | text | YES  |     | NULL    |       |
| keyval   | text | YES  |     | NULL    |       |
| assocval | text | YES  |     | NULL    |       |
*/

if ($args) {
	if (!strstr($args, '==')) {
		print "format: key == value\n";
		exit;
	}

	$t = explode('==', $args);
	$t[0] = chop($t[0]);
	$t[1] = chop($t[1]);
	$a = mqns("select * from whatis where lcase(keyval) = lcase('{$t[0]}') limit 1");
	if ($a) {
		print "but " . $a[0][nick] . " already taught me that " . $a[0][keyval] . " is " . $a[0][assocval] . "\n";
		print "\n";
		exit;
	} else {
		@mqns("insert into whatis (nick, keyval, assocval) values ('$source', '{$t[0]}', '{$t[1]}')");
		print "ok";
		print "\n";
	}
}

?>
