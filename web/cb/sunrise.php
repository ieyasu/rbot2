<?
	$date = "";
	if($args) $date = urlencode($args);
	$url = "http://www.cmpsolv.com/cgi-bin/sunset?page=bob&exper=new99&loctype=City&loc=fort+collins%2C+co&date=$date&tz=Local&tzcustom=&q=&aviation=yes&day1=yes&colors=white&datefmt=0";

	$file = file_get_contents($url);

	$file = substr($file, 0, 1000);

	preg_match('/<pre>(.*)<\/pre>/s', $file, $matches);

	$date = "";
	$time = "";
	$midday = "";
	$twilight_start = "";
	$sunrise = "";
	$sunset = "";
	$twilight_end = "";

	$lines = explode("\n", $matches[1]);
	foreach($lines as $line) {
		if(preg_match("/For\s+(.*)/", $line, $matches)) $date = $matches[1];
		if(preg_match("/Local time \(above TZ\):\s*(.*)/", $line, $matches)) $time = $matches[1];
		if(preg_match("/Midday at:\s+(.*)/", $line, $matches)) $midday = $matches[1];
		if(preg_match("/Civil Twilight Start:\s+(.*)/", $line, $matches)) $twilight_start = $matches[1];
		if(preg_match("/Sunrise:\s+(.*)/", $line, $matches)) $sunrise = $matches[1];
		if(preg_match("/Sunset:\s+(.*)/", $line, $matches)) $sunset = $matches[1];
		if(preg_match("/Civil Twilight End:\s+(.*)/", $line, $matches)) $twilight_end = $matches[1];
	}

	print "$date: Midday: $midday; Sunrise/set: $sunrise - $sunset; Civil twilight: $twilight_start - $twilight_end";
?>
