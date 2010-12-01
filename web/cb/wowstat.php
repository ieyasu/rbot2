<?
	if(!$args) $args = "lothar";
	ini_set("zend.ze1_compatibility_mode", false);
	$file = file_get_contents("http://www.worldofwarcraft.com/realmstatus/status.xml");
	$xml = simplexml_load_string($file);
	foreach($xml->r as $v) {
		if(strtolower($v['n']) == strtolower($args)) {
			print "{$v['n']} is: ";
			if($v['s'] == 1) print "up";
			else print "down";
			die();
		}
	}

	print "$args not found";
?>
