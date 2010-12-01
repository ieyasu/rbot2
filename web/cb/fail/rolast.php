<?
require('inc/rodb.inc');

if (!$args) {

$a = mqns("select max(time) as last from market");

print "market db last updated: ";

if (time() - strtotime($a[0][last]) < 60*5) {
	print "currently updating\n";
} else {
print $a[0][last];
print "\n";
} 
} elseif($args == 'stats') { 
$a = mqns("select count(*) as cnt from market where day=now()");
$b = mqns("select count(*) as cnt from market");
$c = mqns("select count(distinct concat(itemname, cardlist)) as cnt from market where day = NOW() order by id");

print $a[0][cnt] . " recent records (". $c[0][cnt] . " unique items) | " . $b[0][cnt] . " total records\n";

}else {
require('inc/mfilter.inc');

$l = mqns("
        select * from market where $filter and to_days(now()) - to_days(day) = 0 order by 
itemname, cost asc");
if ($l) {

$i = 0;
foreach($l as $k=>$v) {
        $p[$v[itemname]][itemname] = $v[itemname];
	$p[$v[itemname]][prc][$v[cardlist]][$v[cost]] += $v[qty];

#        $p[$v[itemname]][prices] .= "$v[qty] @ " . number_format($v[cost]) . "z " . 
#		($v[cardlist]?"($v[cardlist])":"") ."| ";

#        $p[$v[itemname]][qty] += $v[qty];
# 	if ($i++ > 20) break;

}

$j = array_keys($p);
foreach($p[$j[0]][prc] as $k=>$v) {
	foreach($v as $kk=>$vv) {
		$ilist[] = ($vv>1?"$vv @ ":"") . number_format($kk) . 'z' .  ($k?" ($k)":"");
	}
}

print $p[$j[0]][itemname] . " : " . implode(' | ', $ilist) . "\n";
} else {
print "no info found\n";
}



}

?>
