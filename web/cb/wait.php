<?
if (!$args) {
	print "enter time in seconds to sleep\n";
	exit;
}

if ($args + 0 == $args) {
	if ($args < 50) {
		print "sleeping $args\n";
		flush();
		sleep($args);
		print "slept $args\n";
		flush();
	}
}
?>

