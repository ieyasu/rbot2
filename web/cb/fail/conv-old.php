<?
require('inc/cbotdb.inc');

	$url = "http://www.google.com/search?q=" . urlencode($args) . "&btnI=I%27m+Feeling+Lucky";
	$ch = curl_init ($url);
	$fp = fopen ("/tmp/googlecalc_asdf.txt", "w");
	
	curl_setopt ($ch, CURLOPT_FILE, $fp);
	curl_setopt ($ch, CURLOPT_HEADER, 0);
	
	curl_exec ($ch);
	curl_close ($ch);
	fclose ($fp);
        $fd = fopen("/tmp/googlecalc_asdf.txt", "r");
        //socket_set_timeout($fd, 2);
        $pagesrc = fread($fd, 85000);
        fclose($fd);
        $regex = "/<font size=\+1><b>([^<]+)<\/b>/";
		$nomatch = 1;
            $lines = explode("\n", $pagesrc);
            foreach ($lines as $line) {
		$line = str_replace("<font size=-2> ", ",", $line);
		$line = str_replace("<sup>", "^", $line);
		$line = str_replace("</sup>", "", $line);
		$line = str_replace("&times;", "*", $line);
		$line = str_replace("<font size=-2>", "", $line);
		$line = str_replace("</font>", "", $line);
               preg_match($regex, $line, $matches);
               if (count($matches) > 0) {
		$nomatch = 0;
		break;
		}
	    }

	if($nomatch == 1) {
		print "No result\n";
	} elseif (count($matches) > 0) {
              print "Result: " . $matches[1] . "\n";
	if ($dest[0] == '#') { 

	}
	}


?>
