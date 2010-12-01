<?
  $text = urlencode($args);
  $fp = fsockopen("127.0.0.1", 2001);
  fwrite($fp, "POST / HTTP/1.1\r\nUser-Agent: Opera/7.0 (Windows NT 5.1; U)  [en]\r\nHost: rancom.net:2001\r\nAccept: text/html\r\nReferer: http://ramcon.net:2001/\r\nCookie: $Version=1; jsessionid=ohd0tg8c; alicebot_user=webuser104527996546121203; alicebot_password=104527996546121203\r\nContent-length: 9\r\n\r\ntext=asdf");
  //fwrite($fp, "GET / HTTP/1.1 text=asdf\r\n\r\n");
  $pagesrc = fread($fp, 2000);
  fclose($fp);
  $lines = explode("\n", $pagesrc);
  print("<pre>");
  print_r($lines);
?>
