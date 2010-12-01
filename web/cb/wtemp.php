<?
	$src = file("http://www.weather.com/weather/local/$args");
	foreach($src as $line) {
		if(preg_match("/OAS_query = '(.*)'/", $line, $matches)) {
			$data = split("&", $matches[1]);
			print_r($data);
		}
	}
?>
