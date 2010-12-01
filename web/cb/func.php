<?

$args = str_replace('_', '-', $args);

$a = @file("/home/gurov/w3rd/php/function.$args.html");
if (!$a) {
	print "function not found\n";
	exit;
}
$a = implode('', $a);
$a = str_replace("\n", '', $a);

$mt = preg_match("/Description<\/H2\>(.*)\<BR\>\<\/BR\>/", $a, $matches);

if (!$mt) {
	$nmt = preg_match("/Alias of \<AHREF=\".*\"\>\<BCLASS=\"function\"\>(.*)\<\/B\>\<\/A/", $a, $matches);
	if ($nmt) {
		print "$args is alias of $matches[1]\n";
	}
} else {

$func = strip_tags($matches[1]);


print "SYNTAX: $func \n";
}

?>
