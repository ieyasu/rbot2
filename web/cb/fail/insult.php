<?
  $name = $args;
  $fd = fopen("http://www.pangloss.com/seidel/Shaker/", "r");
  if(!$fp)
    die("Error: no webpage for you!");

  $pagesrc = fread($fp, 10000);
  fclose($fp);
  $lines = explode("\n", $pagesrc);
    foreach ($lines as $line) {
    # $line = preg_replace("/<[^>]+>/", "<", $line);
    preg_match("/(.*)<\/font>/", $line, $matches);
    if (count($matches) > 0) break;
  }
  if (count($matches) > 0) {
    # $matches[1] = preg_replace("/<+/", "<", $matches[1]);
    $matches[1] = preg_replace("/\[/", "", $matches[1]);
    $matches[1] = preg_replace("/\]/", "", $matches[1]);
    $matches[1] = preg_replace("/<br>/", " ", $matches[1]);
    # $stuff = split("<", $matches[1]);
    if($name)
      print("!next " . $name . " $matches[1]");
    else
      print("$matches[1]");
  }
  else
    irc_privmsg($dest, "Error, no regex match.");
?>
