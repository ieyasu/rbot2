#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$file = file_get_contents("http://www.godlessgeeks.com/LINKS/GodProof.htm");
	$file = preg_split("/<li>/", $file);
	$proof = $file[mt_rand(0, count($file)-1)];
	$proof = strip_tags($proof);
	$proof = html_entity_decode($proof);
	$proof = str_replace("\r", " ", $proof);
	$proof = str_replace("\n", " ", $proof);
	$proof = utf8_decode($proof);
	$proof = str_replace("▒", "'", $proof);
	$proof = str_replace("▒", "", $proof);
	$proof = str_replace("▒", "", $proof);
	$proof = str_replace("▒", "", $proof);
	reply($proof);
?>
