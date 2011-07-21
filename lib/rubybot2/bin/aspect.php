#!/usr/bin/php
<?
	require_once("boilerplate.php");
	if(strlen($args) < 1) reply_exit("Return the aspect ratio for 2 numbers, e.g. 16:9, 4:3, etc.");
	$numbers = get_numbers($args);
	if(count($numbers) < 2) reply_exit("Please provide 2 numbers");
	if(count($numbers) > 2) reply_exit("Please provide only 2 numbers");
	$num1 = $numbers[0];
	$num2 = $numbers[1];
	if($num1 <= 0 || $num2 <= 0) reply_exit("Please use only positive numbers");

	while(!is_whole($num1) || !is_whole($num2)) {
		$num1 *= 10;
		$num2 *= 10;
	}

	$num1 = (int) $num1;
	$num2 = (int) $num2;

	$ratio = get_ratio($num1, $num2);
	$ratio = clean_ratio($ratio);

	$numstr = $numbers[0] . ":" . $numbers[1];
	reply($numstr . " is " . $ratio);

	function is_whole($num) {
		return abs((int) $num - $num) < .000001;
	}

	function get_numbers($str) {
		$str = preg_replace("/-([^0-9.]|$)/", "", $str);
		return preg_split("/[^-0-9.]+/", $str, -1, PREG_SPLIT_NO_EMPTY);
	}

	function get_ratio($num1, $num2) {
		$gcd = gcd($num1, $num2);
		$num1 /= $gcd;
		$num2 /= $gcd;
		return "$num1:$num2";
	}

	// credit to http://php.net/manual/en/ref.math.php
	function gcd($n, $m) {
		$n = (int) $n;
		$m = (int) $m;
		$n=abs($n); $m=abs($m);
		if ($n==0 and $m==0)
			return 1; //avoid infinite recursion
		if ($n==$m and $n>=1)
			return $n;
		return $m<$n?gcd($n-$m,$n):gcd($n,$m-$n);
	}

	function clean_ratio($ratio) {
		if($ratio == "8:5") return "16:10 (8:5)";
		if($ratio == "5:8") return "10:16 (5:8)";
		if($ratio == "37:20") return "1.85:1 (37:20)";
		if($ratio == "20:37") return "1:1.85 (20:37)";
		if($ratio == "239:100") return "2.39:1 (239:100)";
		if($ratio == "100:239") return "1:2.39 (100:239)";
		return $ratio;
	}
?>
