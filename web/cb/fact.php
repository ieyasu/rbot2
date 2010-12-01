<?
	while(true) {
		$content = `wget -T 10 http://en.wikipedia.org/wiki/Special:Random -O- -o /dev/null`;

		$doc = new DOMDocument();
		@$doc->loadHTML($content);

		$i = 0;

		foreach($doc->getElementsByTagName("p") as $v) {
			$text = $v->nodeValue;
			if(preg_match("/^[^\.]+/", $text, $matches)) {
				if(!strpos($matches[0], " is ")) break;
				print $matches[0] . ".\n";
				die();
			} else {
				die("Error parsing page.");
			}
		}
	}
?>
