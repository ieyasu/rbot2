<?
         $url = "http://www.frii.com/community/movies/viewAll.php";
         
         $fd = fopen($url, "r");
         if ( !$fd ) {
	    print "GGGGGIB\n";
         } else {
            socket_set_timeout($fd, 2);
            $pagesrc = fread($fd, 41000);
            fclose($fd);

	    $lines = explode("\n", $pagesrc);
	    $match = 0;
	    $fail = 1;
	    $countlines = 0;

	    for($i=1;$i<count($lines);$i++) {
		if(stristr($lines[$i], "Listings for")) {
			preg_match("/Listings for (.*)</", $lines[$i], $matches);
			$currplace = $matches[1];
		}
		if(stristr($lines[$i], "viewMovie.php")) {
			preg_match("/viewMovie.php.movieID=\d+..([^<]*)</", $lines[$i], $matches);
			$currmovie = $matches[1];
		}
		if(preg_match("/<p>\d/", $lines[$i])) {
			preg_match("/<p>(\d.*)</", $lines[$i], $matches);
			$times = $matches[1];
			if(preg_match("/$args/i", $currmovie)) {
			#$i = count($lines)+1; 
			    $match = 1;
			}
		}
		if($currplace == "Metrolux 12") {$match = 0;}

	        if(($currmovie && $currplace && $times) && ($match == 1) && ($countlines < 2)) {
                    print "$currmovie: $currplace: $times\n";
		    $countlines++;
		    $match = 0; $fail = 0;
	        }
	    }
            if($fail) {
		print "Error retrieving movie information.\n";
	    }
         }
      
?>
