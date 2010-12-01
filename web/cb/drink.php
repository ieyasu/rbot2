<?
  if(!$args)
    print("Please specify a drink name.");
  else {
    $search = urlencode($args);
    $fp = fsockopen("www.webtender.com", 80);
    if(!$fp) die("cannot access webtender.com");
    
    fwrite($fp, "GET /cgi-bin/search/?name=$search&what=drink&show=10 HTTP/1.0\r\n\r\n");
    $pagesrc = null;
    while(!feof($fp)) {
      $pagesrc .= fread($fp, 512);
    }
    fclose($fp);

    $lines = explode("\n", $pagesrc);
    for($i = 1; $i < count($lines); $i++)
      if(preg_match("/\/db\/drink\/(.*)\"/", $lines[$i], $matches))
        $i = count($lines);
    if(count($matches) == 0)
      die("Drink not found.");

    $drinkno = $matches[1];
    
    $fp = fsockopen("www.webtender.com", 80);
    fwrite($fp, "GET /db/drink/$drinkno HTTP/1.0\r\n\r\n");
    $pagesrc = null;
    while(!feof($fp)) {
      $pagesrc .= fread($fp, 512);
    }
    fclose($fp);
    
    $lines = explode("\n", $pagesrc);
    $j = 0;
    $flag = null;

    for($i = 1; $i < count($lines); $i++) {
      if(preg_match("(TITLE\>.*\:(.*)\<\/TIT)", $lines[$i], $matches))
        $drink = $matches[1];
      if((preg_match("(\/TD)", $lines[$i])) && ($flag))
        $flag = null;
      if(preg_match("(\<H1\>)", $lines[$i]))
        $flag = "on";

      if($flag) {
        $results[$j] = $lines[$i];
        $j++;
      }
    }
    print('\001PRIVATE'.trim($drink)."\n");
    for($l = 1; $l < count($results); $l++) {
      $results[$l] = preg_replace("(\<A.*\"\>)", "", $results[$l]);
      $results[$l] = preg_replace("(\<H3.*\>)", "", $results[$l]);

      $results[$l] = str_replace("<P>", "", $results[$l]);
      $results[$l] = str_replace("</P>", "", $results[$l]);
      $results[$l] = str_replace("<UL>", "", $results[$l]);
      $results[$l] = str_replace("</UL>", "", $results[$l]);
      $results[$l] = str_replace("<LI>", "", $results[$l]);
      $results[$l] = str_replace("</A>", "", $results[$l]);

      print('\001PRIVATE'.$results[$l]."\n");
    }
  }
?>

