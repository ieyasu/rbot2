<?
  die("!jdict has been depreciated.  Use !jtoe <romanji> and !etoj <english> instead.");

  if(!$args)
    die("Shows the meaning of the inputted japanese word.  Accepts Romanji input only.  Usage: !jdict <word>");
  $query = $args;
  
  @$fp = fsockopen("www.csse.monash.edu.au", 80, $en, $es, 5);

  if(!$fp)
    die("Could not access.");
  
  fwrite($fp, "POST /cgi-bin/cgiwrap/jwb/wwwjdic?1E HTTP/1.0\r\n");
  fwrite($fp, "Content-Length: ".strlen("&dicsel=1dsrchtype=J&dsrchkey=".$args)."\r\n\r\n");
  fwrite($fp, "dsrchtype=J&dsrchkey=$args&dicsel=1");
    
  while(!feof($fp)) { 
    $src .= fread($fp, 512);
  }

  fclose($fp);
  
  $lines = explode("\n", $src);
  foreach($lines as $line) {
    preg_match("/CHECKED.*  (.*)$/", $line, $matches);
    if($matches && !$outstr) {
      $outstr = $matches[1];
    }
  }
  if($outstr)
    print($outstr);
  else
    print("Not found");
?>

