<?
  if($args || !$number)
    die("sprintsms.php is not meant to be used directly, and only exists because bascule is lazy.");

  $msg = urlencode($msg);

  if(strlen($msg) > 160)
    $msg = substr($msg, 0, 160);

  $poststr = "/textmessaging/composeconfirm";
  $poststr .= "&phoneNumber=$number";
  $poststr .= "&message=$msg";
  $poststr .= "&characters=".(160 - strlen($msg));
  $poststr .= "&callBackNumber=";

  $fp = fsockopen("messaging.sprintpcs.com", 80, $es, $en, 5);
  fwrite($fp, "POST /textmessaging/composeconfirm HTTP/1.0\r\n");
  fwrite($fp, "Content-Length: ".strlen($poststr)."\r\n");
  fwrite($fp, "Host: messaging.sprintpcs.com:80\r\n");
  fwrite($fp, "Content-Type: application/x-www-form-urlencoded\r\n");
  fwrite($fp, "Connection: close\r\n\r\n");
  fwrite($fp, $poststr);
  fclose($fp);
?>

