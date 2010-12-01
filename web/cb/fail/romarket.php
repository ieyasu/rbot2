<?
require('inc/rodb.inc');

if (!$args) {
print "romarket <itemname regex> [with card regex]\n";
exit;
}

# $args = explode(' ', $args);
# $sample = $args[0];

# array_shift($args);
# $args = implode(' ', $args);


require('inc/mfilter.inc');



$a = mqns("select count(*) as cnt, sum(qty) as items from market where $filter");
if(!$a) { print "no info found\n"; exit; }
print $a[0][items] . " items ";
print $a[0][cnt] . " records: ";
$sample = 1;
$a = mqns("select * from market where $filter order by time desc limit $sample");
if (!$a) { print "no info found\n"; exit; }
$cost = 0;
$qty = 0;
foreach($a as $k=>$v) {
	$cost += $v[cost]*$v[qty];
	$qty += $v[qty];
}
print "$sample: " . number_format(floor($cost/$qty)) . "  ";

$sample = 5;
$a = mqns("select * from market where $filter order by time desc limit $sample");
if (!$a) { print "no info found\n"; exit; }
$cost = 0;
$qty = 0;
foreach($a as $k=>$v) {
	$cost += $v[cost]*$v[qty];
	$qty += $v[qty];
}
print "$sample: " . number_format(floor($cost/$qty)) . "  ";

$sample = 10;
$a = mqns("select * from market where $filter order by time desc limit $sample");
if (!$a) { print "no info found\n"; exit; }
$cost = 0;
$qty = 0;
foreach($a as $k=>$v) {
	$cost += $v[cost]*$v[qty];
	$qty += $v[qty];
}
print "$sample: " . number_format(floor($cost/$qty)) . "  ";

$a = mqns("select * from market where $filter");
if (!$a) { print "no info found\n"; exit; }
$cost = 0;
$qty = 0;
foreach($a as $k=>$v) {
	$cost += $v[cost]*$v[qty];
	$qty += $v[qty];
}
print "all: " . number_format(floor($cost/$qty)) . "  ";
?>
