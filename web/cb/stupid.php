<?
	$file = file("http://stupidfilter.org/random.php");
	$parts = split("<td>", $file[6]);
	print "(Rating: " . trim(strip_tags($parts[5])) . ") ";
	print trim(strip_tags($parts[3]));
	print "\n";
?>
