<?
  if(!$args) {
    print(date("M jS, Y g:i:s a T")."\n");
  }
  elseif(is_numeric($args)) {
    //convert unix time -> normal
    $unix = $args;
    print("Unix time $unix == ".date("M jS, Y g:i:s a T", $unix)."\n");
  }
  else {
    //attempt to convert normal -> unix
    $unix = strtotime($args);
    $newdate = date("m/d/Y g:i:s a T", $unix);
    if($unix > 0)
      print("'$args' == $newdate == $unix Unix time\n");
    else
      die("$args is not a valid date/time\n");
  }
?>
