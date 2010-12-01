<?
require('inc/ircdb.inc');


if (!$args) {
	print "!roxp <monster type> <minhp> <maxhp>\n";
	exit;
} else {
	$args = explode(' ', $args);
	if (count($args) != 3) {
		print "see syntax\n";
		exit;
	}

	$a = mqns("select * from monster where type like '%$args[0]%' and hp >= '$args[1]' and hp <= '$args[2]' order by hp desc limit 3");
	
	if ($a) {
	foreach($a as $k=>$v) {
		$thing[] = "$v[name] ($v[hp] hp $v[exp]/$v[jexp])";
#		print str_pad($v[name], 20, ' ',  STR_PAD_RIGHT) . "$v[hp]hp $v[exp]/$v[jexp]exp $v[type] $v[def]/$v[mdef] df/md\n";
	}

	print implode(', ', $thing);
	print "\n";
	} else {
		print "no such thing found\n";
	}
}
?>
