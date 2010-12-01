#!/usr/bin/php
<?php
require_once("boilerplate.php");

$content = file_get_contents("http://www.fmylife.com/random");
$content = strip_tags($content);

preg_match_all('/Today,.*?FML/',$content,$fmls);

$random = $fmls[0][rand(0,count($fmls[0])-1)];
reply(html_entity_decode(stripslashes($random)));

?>
