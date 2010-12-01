<?

if (!$args) {
	print "tempo <bpm> <beatstring> <loops>\n";
	exit;
}

$i=0;

$a = explode(' ', $args);

$num = abs(60000000 / $a[0] );

if ($num > 90000000) {
	print "error\n";
	exit;
}
if (strlen($a[1]) == 0) $a[1] = '00ntz';

if ($a[2] > 3) $a[1] = '*' . $a[1];

if (!$a[2] || $a[2] > 60) $a[2] = 3;

for ($i=0;$i<$a[2];$i++) {
print "$a[1]\n";
flush();
usleep($num);
}


?>
