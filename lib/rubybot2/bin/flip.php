#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$f = array(
		"\x00\x21" => "\x00\xA1",
		"\x00\x22" => "\x20\x1E",
		"\x00\x26" => "\x21\x4B",
		"\x00\x27" => "\x00\x2C",
		"\x00\x28" => "\x00\x29",
		"\x00\x2E" => "\x02\xD9",
		"\x00\x33" => "\x01\x90",
		"\x00\x34" => "\x15\x2D",
		"\x00\x36" => "\x00\x39",
		"\x00\x37" => "\x2C\x62",
		"\x00\x3B" => "\x06\x1B",
		"\x00\x3C" => "\x00\x3E",
		"\x00\x3F" => "\x00\xBF",
		"\x00\x41" => "\x22\x00",
		"\x00\x42" => "\x10\x412",
		"\x00\x43" => "\x21\x83",
		"\x00\x44" => "\x25\xD6",
		"\x00\x45" => "\x01\x8E",
		"\x00\x46" => "\x21\x32",
		"\x00\x47" => "\x21\x41",
		"\x00\x4A" => "\x01\x7F",
		"\x00\x4B" => "\x22\xCA",
		"\x00\x4C" => "\x21\x42",
		"\x00\x4D" => "\x00\x57",
		"\x00\x4E" => "\x1D\x0E",
		"\x00\x50" => "\x05\x00",
		"\x00\x51" => "\x03\x8C",
		"\x00\x52" => "\x1D\x1A",
		"\x00\x54" => "\x22\xA5",
		"\x00\x55" => "\x22\x29",
		"\x00\x56" => "\x1D\x27",
		"\x00\x59" => "\x21\x44",
		"\x00\x5B" => "\x00\x5D",
		"\x00\x5F" => "\x20\x3E",
		"\x00\x61" => "\x02\x50",
		"\x00\x62" => "\x00\x71",
		"\x00\x63" => "\x02\x54",
		"\x00\x64" => "\x00\x70",
		"\x00\x65" => "\x01\xDD",
		"\x00\x66" => "\x02\x5F",
		"\x00\x67" => "\x01\x83",
		"\x00\x68" => "\x02\x65",
		"\x00\x69" => "\x01\x31",
		"\x00\x6A" => "\x02\x7E",
		"\x00\x6B" => "\x02\x9E",
		"\x00\x6C" => "\x05\xDF",
		"\x00\x6D" => "\x02\x6F",
		"\x00\x6E" => "\x00\x75",
		"\x00\x72" => "\x02\x79",
		"\x00\x74" => "\x02\x87",
		"\x00\x76" => "\x02\x8C",
		"\x00\x77" => "\x02\x8D",
		"\x00\x79" => "\x02\x8E",
		"\x00\x7B" => "\x00\x7D",
		"\x20\x3F" => "\x20\x40",
		"\x20\x45" => "\x20\x46",
		"\x22\x34" => "\x22\x35");
	$fliptable = array();
	foreach($f as $k=>$v) {
		$k = mb_convert_encoding($k, "UTF-8", "UTF-16");
		$v = mb_convert_encoding($v, "UTF-8", "UTF-16");
		$fliptable[$k] = $v;
		$fliptable[$v] = $k;
	}
	$ret = "";
	foreach(str_split($args) as $char) {
		if(isset($fliptable[$char])) $ret = $fliptable[$char] . $ret;
		else $ret = $char . $ret;
	}
	reply("(ノ°□°)ノ︵" . $ret);

