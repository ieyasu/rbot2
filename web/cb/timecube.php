<?
	$data = strip_tags(file_get_contents("http://www.timecube.com"));
	$data = preg_replace("/[\r\n]+/", " ", $data);
	$data = explode(". ", $data);
	shuffle($data);
	foreach($data as $str) {
		$str .= ".";
		$str = trim($str);
		$str = htmlspecialchars_decode($str);
		$str = str_replace("&nbsp;", "", $str);
		if(strlen($str) < 10) continue;
		if(strlen($str) > 250) continue;
		if($str{0} == '*') continue;
		print $str;
		break;
	}
?>
