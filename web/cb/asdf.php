<?
die("jkl;");

$a = preg_match("/.*\.(.*)$/", $host, $matches);
print_r($matches);
exit;


print "<pre>";
	$found = 0;
if ($host)
foreach($slist as $k=>$v) {
	$found = whois($host, $v);
	if ($found != 0) break;
}

print $found;

function whois($host, $server) {
        $a = fsockopen($server, 43);
        if (!$a) die ("failure");
        fputs($a, "=$host\n");
        while (!feof($a)) {
                $t .= fgets($a, 128);
        }

        fclose($a);
#       print "<pre>";
        $a = preg_match("/Expiration Date: (.*)/", $t, $m);
#       print_r($m);
        if (strstr($t, 'No match for "') || !$m[1]) return 0; else return $m[1];
}
?>
