<?
	function timeTil($now, $tilArg) {
		if(strtolower($tilArg) == "christmas") $tilArg = "December 25";
		if(is_numeric($tilArg)) $tilArg = $tilArg . ":00";
		$til = strtotime($tilArg, $now);
		if($til === false) return "Time until when?";
		$seconds = $til - $now;
		if($seconds < 0) {
			// Try appending "PM" to see if that makes it positive
			$tilArg = $tilArg . " pm";
			$til = strtotime($tilArg, $now);
			$seconds = $til - $now;
			if($seconds <= 0) return "$tilArg Already past";
		}
		$minutes = (int) ($seconds / 60);
		$seconds = $seconds % 60;
		$hours = (int) ($minutes / 60);
		$minutes = $minutes % 60;
		$days = (int) ($hours / 24);
		$hours = $hours % 24;
		$daystr = "";
		if($days > 0) {
			if($days == 1) $daystr = "1 day ";
			else $daystr = "$days days ";
		}
		$hours = str_pad($hours, 2, "0", STR_PAD_LEFT);
		$minutes = str_pad($minutes, 2, "0", STR_PAD_LEFT);
		$seconds = str_pad($seconds, 2, "0", STR_PAD_LEFT);
		return "$daystr$hours:$minutes:$seconds";
	}
?>
