<?
  if(!$args)
    die("roll some dice...  usage: roll <number of dice>d<faces>, like 3d6");
  $args = str_replace("d", " ", $args);
  $args = str_replace("+", " +", $args);
  $args = str_replace("-", " -", $args);
  $args = preg_replace("/\+\s+/", "+", $args);
  $args = preg_replace("/\-\s+/", "+", $args);
  $args = preg_replace("/\s+/", " ", $args);
  $argv = explode(" ", $args);
  $argv[0] = 0 + $argv[0];
  $argv[1] = 0 + $argv[1];
  if($argv[0] > 10000) die("too big");
  if($argv[1] > 2147483646) die("too big");
  if($argv[0] <= 0) die("too small");
  if($argv[1] <= 0) die("too small");
  if($argv[0] != (int) $argv[0]) {
  	print "Integers please"; die();
  }
  if($argv[1] != (int) $argv[1]) {
  	print "Integers please"; die();
  }
  $mod = 0;
  for($i=2;$i<count($argv);$i++) {
  	if($argv[$i]{0} == '+') {
		$mod += substr($argv[$i], 1);
	} else if($argv[$i]{0} == '-') {
		$mod -= substr($argv[$i], 1);
	}
  }
  $val = 0;
  for($i=0;$i<$argv[0];$i++) {
    @$val2 = mt_rand(1,$argv[1]);
    if($val2 == 0) die("Error rolling dice");
    if(($argv[0] <= 10) && ($argv[0] != 1)) print $val2 . " ";
    $val += $val2;
  }
  if(($argv[0] <= 10) && ($argv[0] != 1)) print ": ";
  print $val;
  if($mod != 0) {
  	print " ";
  	if($mod > 0) print "+";
	print $mod;
	print " = " . ($val+$mod);
  }
?>
