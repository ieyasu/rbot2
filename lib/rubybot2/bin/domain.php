#!/usr/bin/php
<?
require_once("boilerplate.php");

if (!$args) {
	print "usage: domain <name> - returns expiration date, or if it is available\n";
	exit;
}

$found = 0;

if ($args) {
	$a = preg_match("/.*\.(.*)$/", $args, $matches);
    
    $found = whois($args, $matches[1] . ".whois-servers.net");


    if ($found == '0') {
        $found2 = whois("=$args", $matches[1] . ".whois-servers.net");
        if ($found2 == '0') {
            print "$args available\n";
        } else {
            print "$args expires: $found2\n";
        }		
    } else {
		print "$args expires: $found\n";
	
    }
}

function whois($host, $server) {
	$sargs = explode('|', $server);
	$server = $sargs[0];
    $a = @fsockopen($server, 43);
    if (!$a) die ("socket failure");
    fputs($a, "$sargs[1]" . "$host\n");
    while (!feof($a)) {
        $t .= fgets($a, 128);
    }

    fclose($a);
    $a = preg_match("/Expiration Date: *(.*)/", $t, $m);
    $b = preg_match("/Status:(.*)/", $t, $m2);

    if (strstr($t, 'No match for "') || !$m[1]) return 0; else return trim($m[1]) . " - " . trim($m2[1]);
}
?>
