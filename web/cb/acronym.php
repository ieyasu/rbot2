<?
  $fp = fopen("res/acronym.txt", "r");
  $src = fread($fp, 55000);
  fclose($fp);

  $lines = explode("\n", $src);

  foreach($lines as $line) {
    $parts = explode("|", $line);
    if($parts[0] == strtoupper($args))
      die("$parts[0]: $parts[1]");
  }
  print("Not found");
?>
