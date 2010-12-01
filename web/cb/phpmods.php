<?
$a = glob("*.php");

if (!$a) {
	print "no modules\n";
	exit;
}

foreach($a as $fname) {
$n[] = str_replace('.php', '', $fname);
}

print(implode(', ', $n));
print "\n";

?>
