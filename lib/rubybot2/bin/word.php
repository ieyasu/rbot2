#!/usr/bin/php
<?
require_once("boilerplate.php");

$file = curl_get_contents("http://watchout4snakes.com/creativitytools/RandomWord/RandomWord.aspx");

$file = strip_tags($file);
$file = str_replace("&nbsp;", " ", $file);
preg_match("/Your random word is:\s+\w+/", $file, $matches);
$stuff = $matches[0];
$stuff = preg_replace("/\s+/m", " ", $stuff);
reply($stuff);

function curl_get_contents($url) {
    $useragent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"; 
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_USERAGENT, $useragent);
    $output = curl_exec($ch);
    curl_close($ch);
    return $output;
}

?>
