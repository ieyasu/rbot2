<?
  $curtime = date("U");
  if(!$args) {
    print("Korean time: " . date("D m/d/Y G:i", $curtime + 54000));
  }
  else {
    if (($mst = strtotime($args)) === -1)
      print("Unrecognized date format");
    else
      print(date("m/d/Y G:i", $mst)." Korean == ".date("m/d/Y g:i a", $mst - 57600)." MST");
  }
?>
