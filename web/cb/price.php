<?
// this module fucking sucks a frog ass

  if(!$args)
    die("Price information from froogle.com. Usage: !price|froogle [-p max_price] <item>");
  $args = explode(" ", $args);

  if($args[0] == "-p") {
    $maxprice = trim($args[1]);
    array_shift($args);
    array_shift($args);
  }
  $query = implode(" ", $args);
  
  $fp = fopen("http://froogle.google.com/froogle?as_q=".urlencode($query)."&num=25&btnG=Froogle+Search&as_epq=&as_oq=&as_eq=&price=under&price0=$maxprice&price1=&price2=&as_occt=title&cat=0", "r");
  if(!$fp)
    die("Could not access froogle.google.com");
    
  $pagesrc = fread($fp, 200000);
  fclose($fp);
  $pagesrc = str_replace("\n", "", $pagesrc);
  $pagesrc = str_replace("&nbsp;", "", $pagesrc);

  $pagesrc = preg_replace("/<img src=\"\/froogle_image[^>]*>/", "*BREAK*", $pagesrc);
  $pagesrc = preg_replace("/<[^>]*>/", "", $pagesrc);
  $pagesrc = explode("*BREAK*", $pagesrc);
  array_shift($pagesrc);

  $lowprice = 9999999;
  foreach($pagesrc as $line) {
    preg_match("/\\\$([^ ]*)/", $line, $matches);
    $price = $matches[1];
    if($price < $lowprice && $price > 0) {
      $lowprice = $price;
      $outstr = preg_replace("/\\\$([^ ]*)/", "", $line);
      $outstr = "\$$price - $outstr";
    }
  }
  if($outstr) 
    print($outstr);
  else
    print("Not found");
?>

