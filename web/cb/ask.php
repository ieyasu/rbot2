<?
	$args = urlencode(stripslashes(trim($args)));

	$url = "http://start.csail.mit.edu/startfarm.cgi?query=$args";
	$file = file_get_contents($url);
	$parts = get_parts($file);

	$max_len = 600;

	$ans = "";

	foreach($parts as $part) {
		if($part[0] == "PREFACE") continue;
		if(preg_match("/^Source:/", $part[1])) continue;
		if(strlen($ans) + strlen($part[1]) > $max_len) continue;
		$ans .= $part[1];
	}
	
	if(strlen($ans) >= 1) {
		print $ans;
		exit;
	}

	print "A parsing error occurred (answer too long?). See $url";

	function get_parts($text) {
		$text = str_replace("\r", "", $text);
		$text = str_replace("\n", " ", $text);
		$parts = split("REPLY-QUALITY", $text);
		array_shift($parts);
		$res = array();
		foreach($parts as $v) {
			$v = preg_replace("/^[: ]*/", "", $v);
			preg_match("/^(.*)-->/", $v, $mat);
			$responsetype = $mat[1];
			$v = preg_replace("/^.*-->/", "", $v);
			$v = preg_replace("/go back to the start dialog.*/i", "", $v);
			$v = preg_replace("/accept word.*/i", "", $v);
			$possible_answer = strip_tags($v);
			$possible_answer = preg_replace("/--\s*$/", "", $possible_answer);
			$possible_answer = str_replace("&nbsp;", " ", $possible_answer);
			$possible_answer = preg_replace("/\s+/", " ", $possible_answer);
			$possible_answer = trim($possible_answer);
			if($possible_answer == "") continue;
			$respart[0] = $responsetype;
			$respart[1] = $possible_answer;
			$res[] = $respart;
		}
		return $res;
	}
?>
