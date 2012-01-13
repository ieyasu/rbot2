#!/usr/bin/php
<?
require_once("boilerplate.php");
while(true) {
    $content = `wget -T 10 http://en.wikipedia.org/wiki/Special:Random -O- -o /dev/null`;

    $doc = new DOMDocument();
    @$doc->loadHTML($content);

    $i = 0;

    foreach($doc->getElementsByTagName("p") as $v) {
        $text = $v->nodeValue;
        if(preg_match("/^[^\.]+/", $text, $matches)) {
            if(!strpos($matches[0], " is ")) break;
            reply($matches[0]);
        } else {
            reply_exit("Error parsing page.");
        }
    }
}
?>
