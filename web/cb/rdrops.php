<?
  if(!$args)
    die("Please specify a name");

$a = file ("monster_drops.txt");

foreach($a as $k=>$v) {
	$v = trim($v);
	$v = str_replace('"', '', $v);
	$val = explode(',', $v);
	
	$mob = $val[0];
	array_shift($val);

	$args = str_replace(" ", "_", $args);

#	if(stristr($mob, $args)) {
	if(substr(strtolower($mob), 0, strlen($args)) == strtolower($args)) {
		print "$mob: ";
	        $i=0;
       		$cnt = count($val);
        	for ($i=0;$i<$cnt;$i+=2) {
                	# $dropratios[$mob][$val[$i]] = $val[$i+1];
			if($val[$i+1] > 0) {
				print $val[$i]." (".$val[$i+1]." ".($val[$i+1]/100)."%)";
				if($i < $cnt-2) print ", ";
			}
        	}
		die;
	}

}

print "No match";

# print_r($dropratios);

?>
