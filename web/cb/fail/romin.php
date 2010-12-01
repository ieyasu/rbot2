<?
require('inc/rodb.inc');
require('inc/mfilter.inc');


$a = mqns("select *, to_days(NOW())-to_days(time) as ago from market where 
$filter order by cost limit 3");
if (!$a) {
	print "nothing found\n";
	 exit;
}

foreach($a as $k=>$v) {
	if ($v[qty]>1) {
	$tmp = "$v[itemname] - $v[qty]" . " @ " . number_format($v[cost]) . "z ($v[ago] days ago)";

	if (strlen($v[cardlist]) > 3) $tmp .= "($v[cardlist])";

	$p[] = $tmp;

	} else {

	$tmp = "$v[itemname] - " . number_format($v[cost]) . "z ($v[ago] days ago)";

	if (strlen($v[cardlist]) > 3) $tmp .= "($v[cardlist])";

	$p[] = $tmp;
	}
}

print "$args: ";
print (implode(', ', $p));
print "\n";
?>
