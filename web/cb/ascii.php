<?
  $in = $args;
  if(is_numeric($in)) {
    $npArray = array("(nul)", "(soh)", "(stx)", "(etx)", "(eot)", "(enq)", "(ack)", "(bel)", "(bs)", "(ht)", "(nl)", "(vt)", "(np)", "(cr)", "(so)", "(si)", "(dle)", "(dc1)", "(dc2)", "(dc3)", "(dc4)", "(nak)", "(syn)", "(etb)", "(can)", "(em)", "(sub)", "(esc)", "(fs)", "(gs)", "(rs)", "(us)", "(sp)");
    $out = $npArray[$in];
    if(!$out) $out = chr($in);
    print("ASCII char of $in -> $out\n");
  }
  $in = substr(stripslashes($in), 0, 1);
  print("ASCII value of $in -> ".ord($in)." (0x".dechex(ord($in)).")");
?>
