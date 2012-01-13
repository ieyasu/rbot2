#!/usr/bin/php
<?
require_once("boilerplate.php");

$args = str_replace('_', '-', $args);

$a = @file("/home/gurov/w3rd/php/function.$args.html");
if (!$a) {
	reply_exit("function not found\n");
}
$a = implode('', $a);
$a = str_replace("\n", '', $a);

$mt = preg_match("/Description<\/H2\>(.*)\<BR\>\<\/BR\>/", $a, $matches);

if (!$mt) {
	$nmt = preg_match("/Alias of \<AHREF=\".*\"\>\<BCLASS=\"function\"\>(.*)\<\/B\>\<\/A/", $a, $matches);
	if ($nmt) {
		reply("$args is alias of $matches[1]\n");
	}
} else {
    $func = strip_tags($matches[1]);
    reply("SYNTAX: $func \n");
}

?>
