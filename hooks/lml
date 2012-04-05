#!/usr/bin/php
<?
require_once("boilerplate.php");

$content = file_get_contents("http://www.lmylife.com/?sort=random");

preg_match_all('/<p>.*<\/p>/',$content,$fmls);

$random = $fmls[0][rand(0,count($fmls[0])-1)];
reply(trim(stripslashes(strip_tags($random))));
?>
