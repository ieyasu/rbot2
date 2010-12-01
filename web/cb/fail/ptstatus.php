<?
  @$fp = fsockopen("211.39.144.141", 10007, $es, $en, 10);
  if(!$fp)
    print("PT server is not responding");
  else {
    fclose($fp);
    print("PT server is online");
  }
?>

