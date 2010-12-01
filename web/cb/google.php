<?
	ini_set("html_errors", false);
//	$args = "suppleninja";
	$search = urlencode($args);
	$url = "http://www.google.com/search?q=$search&btnI=1";
	$context = stream_context_create(array('http' => array(
		'header' => 'Referer: http://www.google.com\n\n'
	)));
	$fp = fopen($url, 'r', false, $context);
	$meta_data = stream_get_meta_data($fp);
//	print_r($meta_data);
	foreach($meta_data['wrapper_data'] as $item) {
		if(preg_match("/^location: (.*)/i", $item, $matches)) {
			print "URL: " . $matches[1] . "\n";
			die();
		}
	}
	print "No url found\n";
?>
