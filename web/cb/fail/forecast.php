<?
  $zip = $args;
  if(!$zip)
    $zip = 80521;
  if(!is_numeric($zip))
    die("Usage: !forecast [numeric_zipcode].  Defaults to 80521.");
    
  $fp = fopen("http://www.srh.noaa.gov/zipcity.php?inputstring=$zip", "r");
  if(!$fp)
    die("Could not open noaa.gov");
  
  $pagesrc = fread($fp, 15000);
  fclose($fp);
  
  $pagesrc = str_replace("\n", "*N*", $pagesrc);
  $pagesrc = str_replace("<b>", "", $pagesrc);
  $pagesrc = str_replace("</b>", "", $pagesrc);
  $pagesrc = str_replace("</strong></font><br>", "*BEG*", $pagesrc);
  $pagesrc = str_replace("<br><br>*N*</td>", "*END*", $pagesrc);
  $pagesrc = str_replace("<br><br>", "*EOL*", $pagesrc);
  
  preg_match("/\*BEG\*(.*)\*END\*/", $pagesrc, $matches);
  $lines = explode("*EOL*", $matches[1]);
  $line = "*" . $lines[0] . "\n*" . $lines[1] . "\n*" . $lines[2];
  $line = str_replace("*N*", " ", $line);
  $line = str_replace("  ", " ", $line);
  $line = str_replace(" . ", ". ", $line);
  //(.*)\<br\>\<br\>(.*)\<br\>\<br\>(.*)\<br\>\<br\>(.*)\<br\>\<br\>(.*)\<br\>\<br\>(.*)\<br\>\<br\>(.*)\<br\>\<br\>(.*)\<br\>\<br\>/", $pagesrc, $matches);
  //print("<pre>");
  print($line);
?>
