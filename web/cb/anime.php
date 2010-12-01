<?
  if(!$args)
    die("Show release information about anime DVDs.  Usage: !anime <title>");
  $query = stripslashes($args);
  
  $src = file_get_contents("http://www.animeondvd.com/releases/releases_by_date.php");
    
  $src = str_replace("\n", "", $src);
  
  $lines = explode("</tr><tr>", $src);
  array_shift($lines);

  foreach($lines as $line) {
    if(@preg_match("/" . $query . "/i", $line)) {
      $line = preg_replace("/<[^>]*>/", "*BREAK*", $line);
      $info = explode("*BREAK*", $line);
      if($info[16]) {
        die("$info[7]: $info[2] ($info[12], $info[16] mins, \$$info[20] MSRP)");
      }
      else {
	die("$info[7]: $info[2] ($info[12], \$$info[20] MSRP)");
      }
    }
  }
  print("Title not found");
?>

