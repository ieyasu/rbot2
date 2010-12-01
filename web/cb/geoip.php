<?
  if(!$args)
    die("Usage: !geoip <IP or hostname>");
  $args = escapeshellcmd($args); 
  $result = explode(":", exec("/usr/local/bin/geoiplookup $args"));
  print("$args:$result[1]");
?>
