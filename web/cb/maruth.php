<?
  $lines = file("res/maruth.txt");

  $qnum = mt_rand(0, count($lines)-1);

  if(substr($lines[$qnum], 0, 1) == "*")
    $lines[$qnum] = " ".$lines[$qnum];

  print($lines[$qnum]);
?>
  
