<?
  $fp = fopen("http://planet-ro.com/status-irc.php", "r");
  if(!$fp) die("Cannot access planet-ro.com");

  $pagesrc = fread($fp, 2000);
  fclose($fp);
  $lines = explode("\n", $pagesrc);
  print(date("g:ia", $lines[0]));
  print(": $lines[1]");
?>
