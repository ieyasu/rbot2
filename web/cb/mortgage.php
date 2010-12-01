<?
  $arg = explode(" ", $args);
  $P = $arg[0];
  $r = $arg[1];
  $n = $arg[2];
  $d = $arg[3];

  if(!$P || !$r || !$n)
    die("Usage: !mortgage <principle> <rate%> <number of years> [downpayment].  Example: !mortgage 230000 5.5 30");

  $P -= $d;
  $r = round($r / 1200, 5);
  $n = $n * 12;

  $a = $P * (pow((1 + $r),$n) * $r) / (pow((1 + $r), $n) - 1);

  print("Monthly Payment: $".round($a, 2));
?>
