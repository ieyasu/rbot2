#!/usr/bin/php
<?
require_once("boilerplate.php");

if (!$args) {
	reply_exit("tempo <bpm> <beatstring> <loops>\n");
}

$i=0;

$a = explode(' ', $args);

$num = abs(60000000 / $a[0] );

if ($num > 90000000) {
	reply_exit("error\n");
}
if (strlen($a[1]) == 0) $a[1] = '00ntz';

if ($a[2] > 3) $a[1] = '*' . $a[1];

if (!$a[2] || $a[2] > 60) $a[2] = 3;

for ($i=0;$i<$a[2];$i++) {
    reply("$a[1]\n");
    usleep($num);
}

?>
