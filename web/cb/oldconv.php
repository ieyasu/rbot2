<?
  //die("sploit");
  $arg = explode(" ", $args);
  if(count($arg) < 3)
    die("Usage: number from_unit to_unit  (Example: 5 miles kilometers)");
  
  $p1 = str_replace("'", "", $arg[0]);
  $p2 = str_replace("'", "", $arg[1]);
  $p3 = str_replace("'", "", $arg[2]);
  $result = exec("units '$p1 $p2' '$p3' | fgrep '*' | awk '{print $2}'");
  $result = trim(chop($result));
  if(strlen($result) == 0) {
    $result = exec("units '$p2($p1)' '$p3'");
    $result = trim(chop($result));
    if(strlen($result) == 0)
      print("An error occurred during conversion");
    else
      print("Result: " . $result);
  }
  else
    print("Result: " . $result);
?>
