<?
require('inc/rodb.inc');


if (!$args) {
	print "need regex\n";
	exit;
}




$a = mqns("select * from chats where chatname rlike '$args' order by time desc limit 5");

if (!$a) {
	print "nothing found\n";
	exit;
}

foreach($a as $k=>$v) {
	$list[] = $v[chatname] . " @ $v[coords] ";
}


print implode(' | ', $list);
print "\n";

?>
