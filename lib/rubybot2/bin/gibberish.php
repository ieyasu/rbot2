#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$month = date("m");
	$day = date("d");
	$year = date("Y");
	$file = "/home/sargon/log/#hatcave/$month.$day.$year.log";
	$fp = fopen($file, "r");
	$data = array();
	$first = array();
	while(!feof($fp)) {
		$line = trim(fgets($fp));
		if($line{29} != '<') continue;
		$line = preg_replace("/^[^>]+>/", "", $line);
		$chars = str_split($line);
		$p = null;
		foreach($chars as $c) {
			$first[$c]++;
			if($p != null) {
				$data[$p][$c]++;
			}
			$p = $c;
		}
	}
	$l = null;
	$max = mt_rand(50, 150);
	$s = "";
	for($i=0;$i<$max;$i++) {
		$l = get_next_letter($data, $l, $first);
		$s .= $l;
	}
	reply($s);

	function get_next_letter($data, $letter, $first) {
		if($letter == null) {
			// use $first
			return random_distributed($first);
		}
		return random_distributed($data[$letter]);
	}

	function random_distributed($data) {
		$sum = array_sum($data);
		$r = mt_rand(0, $sum);
		$sum_so_far = 0;
		foreach($data as $k=>$v) {
			$sum_so_far += $v;
			if($sum_so_far >= $r) return $k;
		}
		die("error in random_distributed");
	}
?>
