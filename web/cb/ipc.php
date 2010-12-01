<?
echo "punt !\n";
exit;

    $url = "http://ip-to-country.com/get-country/?ip" . $ip . "&user=guest&pass=guest";
    $fp = fsockopen ($url, 80, $errno, $errstr, 30);
    if (!$fp) {
        echo "$errstr ($errno)<br>\n";
    } else {
        fputs ($fp, "GET / HTTP/1.0\r\nHost: " . $url. "\r\n\r\n");
        while (!feof($fp)) {
            echo fgets ($fp,128);
        }
        fclose ($fp);
    }

    function IPAddress2IPNumber($dotted) {
        $dotted = preg_split( "/[.]+/", $dotted);
        $ip = (double) ($dotted[0] * 16777216) + ($dotted[1] * 65536) + ($dotted[2] * 256) + ($dotted[3]);
        return $ip;
    }

    function IPNumber2IPAddress($number) {
        $a = ($number / 16777216) % 256;
        $b = ($number / 65536) % 256;
        $c = ($number / 256) % 256;
        $d = ($number) % 256;
        $dotted = $a.".".$b.".".$c.".".$d;
        return $dotted;
    }

?>
