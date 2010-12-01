#!/usr/bin/php
<?
	require_once("boilerplate.php");
	reply_exit("use !timetill 5");
	$time = mktime(17, 0, 0, date("n"), date("j"), date("Y"));
	$now = time();
	if($now >= $time) reply("already past");
	else {
		$diff = $time - $now;
		$hours = (int) ($diff / (60 * 60));
		$diff -= $hours * 60 * 60;
		$minutes = (int) ($diff / 60);
		$diff -= $minutes * 60;
		$seconds = $diff;
		$hours = str_pad($hours, 2, "0", STR_PAD_LEFT);
		$minutes = str_pad($minutes, 2, "0", STR_PAD_LEFT);
		$seconds = str_pad($seconds, 2, "0", STR_PAD_LEFT);
		$tz = date("e");
		reply("$hours:$minutes:$seconds ($tz)");
	}
?>
