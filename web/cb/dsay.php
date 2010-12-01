<?
set_time_limit(86400);

if (!$args) {
	print "<seconds> <stuff to say>\n";
	exit;
}

$a = explode(' ', $args);

$wait = abs($a[0]);

array_shift($a);

$args = implode(' ', $a);

if ($wait > 60) $wait = 1;

usleep(1000000 * $wait);

print "$args\n";
flush();
?>
