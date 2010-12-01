<?
set_time_limit(86400);

if (!$args || !strstr($args, ';')) {
	print "say <delay>;<stuff to say>\n";
	exit;
}

$a = explode(';', $args);

$wait = abs(strtotime($a[0]) - time());

if ($wait > 21600) {
	print "delay longer than 6 hours\n";
	exit;
}

print "*ok, saying $a[1] in $wait seconds\n";
flush();
sleep($wait);
$a[1] = trim($a[1]);
print "$a[1]";
print "\n";
?>
