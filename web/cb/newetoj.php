<?
  if(!$args)
    die("Translates English to Japanese Romanji.  Usage: !etoj <word>");
  $query = urlencode($args);

  @$fp = fopen("http://dict.regex.info/cgi-bin/j-e/tty/nocolor/dosearch?sDict=on&H=PW&L=E&T=$query&WC=none", "r");

  if(!$fp)
    die("Could not access.");

  $src = null;

  while(!feof($fp)) {
    $src .= fread($fp, 512);
  }

  fclose($fp);

  $lines = explode("\n", $src);
  foreach($lines as $line) {
    if(preg_match("/\<DT\>.*\<I\>(.*)\<\/I\>(.*)$/", $line, $matches) && !$results) {
      $match = $matches[1];
      $results = preg_replace("/<[^>]*>/", "", $matches[2]);
      print("$match: $results\n");
      exit();
    }
  }

  if(!$results)
    print("Not found");

?>

