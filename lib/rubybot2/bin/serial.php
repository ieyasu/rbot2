#!/usr/bin/php
<?
require_once("boilerplate.php");

$search = $args;
$search = urlencode($search);
$url = "http://www.serials.ws/index.php?pop=1&chto=$search";
$raw = "";
$err = "";
      
$file = fopen ($url, "r");
if($file) {
    while (!feof ($file)) {
        $raw .= fgets ($file, 1024);
    }
} else {
    $err = "Error connecting to serials.ws";
}
fclose($file);
      
// Now that we have the raw page, find where it gives the ID of the first result
preg_match("/d\((\d+)\)/m", $raw, $matches);
      
if ( !count($matches) ) {
    $err = "No serial found.";
}
$id = $matches[1];
      
if ( !$err ) {
    // Take the id and query the page with the actual serial #
    $url = "http://www.serials.ws/d.php?n=$id";
         
    $file = fopen ($url, "r");
    $raw = "";
    if($file) {
        while (!feof ($file)) {
            $raw .= fgets ($file, 1024);
        }
    }
    fclose ($file);
         
    preg_match("/wrap>(.*)<\/textarea>/im", $raw, $matches);
    #         print_r($matches);
    if ( !count($matches) ) {
        $err = "Serial found, but there was a problem harvesting it. (10 serial per day limit?)";
    } else {
        $serial = $matches[1];
    }
}
      
if ($err) {
    reply("$err\n");
} else {
	reply("Serial: $serial\n");
}

?>
