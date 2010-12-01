<?
  $zip = $args;
  if(!$zip)
    $url = "http://www.srh.noaa.gov/data/forecasts/COZ038.php?warncounty=COC069&city=Fort+Collins";
  else {
    if(!is_numeric($zip))
      die("Usage: !forecast [numeric_zipcode].  Defaults to 80521.");
    else
      $url = "http://www.srh.noaa.gov/zipcity.php?inputstring=$zip";
  }


  @$fp = fopen($url, "r");
  if(!$fp)
    die("*Could not connect to NOAA ($url)");
  
  $pagesrc = fread($fp, 15000);
  fclose($fp);
  
  $pagesrc = str_replace("\n", "*N*", $pagesrc);
  $sections = explode("Detailed Forecast", $pagesrc);
  $lines = explode("<br><br>*N*<b>", $sections[1]);
  $first = explode("<b>", $lines[0]);

  $line = "*$first[1]\n*$lines[1]\n*$lines[2]\n*$lines[3]\n*$lines[4]";
  $line = str_replace("*N*", " ", $line);
  $line = str_replace("</b>", "", $line);
  $line = str_replace("  ", " ", $line);
  $line = str_replace(" . ", ". ", $line);
  print($line);

?>
