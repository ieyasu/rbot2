<?
  if(!$args)
    die("Find kbb value for cars.  Usage: !kbb <year> <make> <model>");
  $query = stripslashes($args);
  
  $src = file_get_contents("http://www.animeondvd.com/releases/");
    
  $src = str_replace("\n", "", $src);
  $src = str_replace("&nbsp;", "", $src);
  $src = str_replace("<tr>", "*BREAK*", $src);
  $src = explode("/images/aodupcoming.gif", $src);
  $src = explode("Music Releases</a>", $src[1]);
  
  $lines = explode("*BREAK*", $src[0]);
  $i = 2;
  while(!$outstr && $i < count($lines)) {
    $i++;
//    if(stristr($lines[$i], $query)) {
    if(@preg_match("/" . $query . "/i", $lines[$i])) {
      $line = $lines[$i];
      $line = preg_replace("/<a name=\"\d+\">([^>]+)<\/a>/", "$1", $line); // fix for .hack (sargon)
      $line = preg_replace("/<[^>]*>/", "*BREAK*", $line);
      $info = explode("*BREAK*", $line);
      $outstr = trim($info[2])." (".trim($info[8]).", vol ".trim($info[19]).", \$".trim($info[24])."): ".trim($info[29]);
    }
  }
  if($outstr) 
    print($outstr);
  else
    print("Title not found");
?>

