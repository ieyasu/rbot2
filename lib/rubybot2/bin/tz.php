#!/usr/bin/php
<?
	$format = "m/d/y h:i:s a"; // format used for all output
	require_once("boilerplate.php");
	function usage() {
		reply_exit("Convert a time between time zones. Usage: !tz <time> <fromtz> [[to] totz], !tz <time> [to] <totz>");
	}
	function is_tz($tz) {
		try {
			$tz = new DateTimeZone($tz);
		} catch(Exception $e) {
			return false;
		}
		return true;
	}
	function validate_tz($tz) {
		if($tz == "") return false;
		$ids = DateTimeZone::listIdentifiers();
		// find the shortest time zone that contains $tz
		$shortest = -1;
		$ret_tz = $tz;
		foreach($ids as $n=>$val) {
			if(preg_match("@(^|/)$tz$@i", $val)) {
				$len = strlen($val);
				if($shortest == -1 || $shortest > $len) {
					$ret_tz = $val;
					$shortest = $len;
				}
			}
		}
		if(is_tz($ret_tz)) return $ret_tz;
		return false;
	}
	if($args == "") usage();
	// cases:
	// 1: words words words fromtz
	// 2: words words words fromtz to totz
	// 3: words words words fromtz totz
	// 4: words words words to totz
	$fromtz = "America/Denver";
	$totz = "America/Denver";

	$num_args = count($arg);
	$last_arg = $arg[$num_args - 1];
	if($num_args >= 2) $second_arg = $arg[$num_args - 2];
	else $second_arg = "";
	if($num_args >= 3) $third_arg = $arg[$num_args - 3];
	else $third_arg = "";

	if($second_arg == "to") {
		// cases 2 or 4
		$totz = $last_arg;
		$time_ends = $num_args - 2;
		if(validate_tz($third_arg)) {
			$fromtz = $third_arg;
			$time_ends = $num_args - 3;
		}
	} else {
		// cases 1 or 3
		if(!validate_tz($second_arg)) {
			$fromtz = $last_arg;
			$time_ends = $num_args - 1;
		} else {
			$fromtz = $second_arg;
			$totz = $last_arg;
			$time_ends = $num_args - 2;
		}
	}
	$fromtz = validate_tz($fromtz);
	$totz = validate_tz($totz);
	if($fromtz === false) usage();
	if($totz === false) usage();

	// parse off time
	$time = join(" ", array_slice($arg, 0, $time_ends));
	try {
		$dt = new DateTime($time, new DateTimeZone($fromtz));
		$time = $dt->format($format);
		$dt->setTimezone(new DateTimeZone($totz));
		$newtime = $dt->format($format);
		reply_exit("$time $fromtz is $newtime $totz");
	} catch (Exception $e) {
		usage();
	}

//	reply_exit("01/10/10 10:00 Mountain is 01/10/10 10:00 Mountain");
?>
