<?
  @$fp = fopen("http://ps.crgaming.com/serverstatus.html", "r");
  if(!$fp)
    die("Could not access");
    
  $pagesrc = fread($fp, 30000);
  fclose($fp);
  $pagesrc = str_replace("\n", "", $pagesrc);
  $pagesrc = str_replace("</tr><tr>", "*B*", $pagesrc);
  $pagesrc = str_replace("</td><td>", "*B*", $pagesrc);
  $pagesrc = str_replace("&nbsp;", "", $pagesrc);
  $pagesrc = preg_replace("/<[^>]*>/", "", $pagesrc);

  $lines = explode("*B*", $pagesrc);
  $update = $lines[11]." ".$lines[12];
  $uptime = date("D g:i a", strtotime($update));
  $outstr = "$uptime: $lines[1]: $lines[2]  $lines[7]: $lines[8]";
  print($outstr);
?>

