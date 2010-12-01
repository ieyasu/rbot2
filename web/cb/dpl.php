<?
require('inc/cbotdb.inc');

if (!$args) {
	print "usage: dpl [product]\n";
	exit;
}
$a = mqns("select * from dpl where concat(manuf,' ', product) like '%$args%'");
if (!$a) { print "not found\n"; exit; }
print "{$a[0][manuf]} - {$a[0][product]} - l:{$a[0][userid]} - p:{$a[0][password]} \n";


?>
