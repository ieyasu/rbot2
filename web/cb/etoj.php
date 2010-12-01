<?
	if(stristr($_SERVER[SCRIPT_NAME], "jdict"))
		die("!jdict cannot be used directly.  Please use !etoj (English -> Japanese) or !jtoe (Japanese -> English)\n");
	if(stristr($_SERVER[SCRIPT_NAME], "jtoe")) $nihongo = true;
	
	if(!$args) {
		if($nihongo) {
			die("Shows the English translation of the inputted Japanese word.  Accepts romaji input only.  Usage: !jtoe <word>");
		}
		else {
			die("Shows the Japanese translation of the inputted English word.  Usage: !etoj <word>");
		}
	}
	  	
	$query = $args;

	@$fp = fsockopen("www.freedict.com", 80, $en, $es, 5);

	if(!$fp)
		die("Could not access freedict.");

	fwrite($fp, "POST /onldict/onldict.php HTTP/1.1\r\n");
	fwrite($fp, "User-Agent: Opera/8.50 (Windows NT 5.1; U; en)\r\n");
	fwrite($fp, "Host: www.freedict.com\r\n");
	fwrite($fp, "Referer: http://www.freedict.com/onldict/jap.html\r\n");
	fwrite($fp, "Connection: Close\r\n");
	fwrite($fp, "Content-Type: application/x-www-form-urlencoded\r\n");
  
	if($nihongo) {
		$post = "search=$query&exact=true&max=10&from=Japanese&to=English&fname=eng2jap2&back=jap.html";
	}  
	else {
		$post = "search=$query&exact=true&max=10&from=English&to=Japanese&fname=eng2jap1&back=jap.html";
	}
	
	$cl = strlen($post);
	
	fwrite($fp, "Content-Length: $cl\r\n\r\n");
	fwrite($fp, "$post\r\n");

	while(!feof($fp)) {
		$src .= fread($fp, 512);
	}

	fclose($fp);
  
//	print($src);
	$src = str_replace("\n", "", $src);

	preg_match("/result-l-blue\">([^<]+)/", $src, $mfrom);
	preg_match_all("/result-r-blue\"><strong>([^<]+)/", $src, $mto);

	//print_r($mfrom);
	//print_r($mto);
	
	
	if($mto[1]) {
		$outto = implode("; ", $mto[1]);
		print("$mfrom[1]: $outto\n");
	}
	else {
		print("Not found\n");
	}
?>
