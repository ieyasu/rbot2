<?
#require('inc/cbotdb.inc');

	$args = stripslashes($args);
	$url = "http://www.google.com/search?q=" . urlencode($args) . "+claim+status+site%3Asnopes.com&btnI=I%27m+Feeling+Lucky";
	$ch = curl_init ($url);
	$fp = fopen ("/tmp/snopes_asdf.txt", "w");
	
	curl_setopt ($ch, CURLOPT_FILE, $fp);
	curl_setopt ($ch, CURLOPT_HEADER, 0);
	
	curl_exec ($ch);
	curl_close ($ch);
	fclose ($fp);
        $fd = fopen("/tmp/snopes_asdf.txt", "r");
        //socket_set_timeout($fd, 2);
        $pagesrc = fread($fd, 10000);
        fclose($fd);
        $regex = "/HREF..(.*)..here/";
		$nomatch = 0;
            $lines = explode("\n", $pagesrc);
            foreach ($lines as $line) {
				if(strstr($line, '<html><head><meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=ISO-8859-1"><title>Google Search:')) {
				$nomatch = 1; break; 
			    }
               preg_match($regex, $line, $matches);
               if (count($matches) > 0) break;
	    }

	if($nomatch == 1) {
		print "No matches\n";
		exit();
	} elseif (count($matches) > 0) {
		$url = $matches[1];
	}

	$content = file_get_contents($url);

	// ahackahackahack
	if(strlen($content) < 200) {
		$url = preg_replace("/html?$/", "asp", $url);
		$content = file_get_contents($url);
	}
	$content = strip_tags($content);
	$content = preg_replace("/&nbsp;?/", " ", $content);
	$content = preg_replace("/ +/", " ", $content);
	$content = preg_replace("/Status:\s+\n/", "Status: ", $content);
	$content = str_replace("Status:\n", "Status: ", $content);
	$content = str_replace("Status: \n", "Status: ", $content);
	$content = explode("\n", $content);
	$hit = 0;
	foreach($content as $line) {
		$line = trim($line);
		if(preg_match("/Claim:/", $line, $matches)) {
			$hit = 1;
			$outstr = $line;
		}
		if(preg_match("/Status:/", $line, $matches)) {
			$outstr .= " " . $line;
		}
	}

	$outstr = preg_replace("/ +/", " ", $outstr);
	if($hit == 1) {
		if(strstr($url, "/lost/")) $outstr = "(LOST) " . $outstr;
		print $outstr . " " . $url;
	}
	else print "Page found, but no 'Claim:' match: $url";

?>
