#!/usr/bin/php
<?
	$files = glob("test-*.php");
	$num_run = 0;
	foreach($files as $file) {
		if($file == "test-framework.php") continue;
		$num_run++;
		echo "$file\n";
		system("php $file");
	}
	print "$num_run tests run\n";
?>
