#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$args = trim($args);
	if($args == "") reply_exit("Give me an integer to convert to asdf");
	if(!is_numeric($args)) {
		if(!preg_match("/^z?[asdf]*$/", $args)) reply_exit("Has to be z?[asdf]* or numeric");
	}
	reply($args . " is " . eitherway($args));
	function convertToLetters($num) {
		$num = preg_replace("/\..*/", "", $num);
		$num = (int) $num;
		$neg = false;
		if($num < 0) {
			$neg = true;
			$num = abs($num);
		}
		$n = base_convert($num, 10, 4);
		$n = str_replace("0", "a", $n);
		$n = str_replace("1", "s", $n);
		$n = str_replace("2", "d", $n);
		$n = str_replace("3", "f", $n);
		if($neg == true) $n = "z" . $n;
		return "" . $n;
	}
	function convertToNum($letters) {
		$letters = preg_replace("/\..*/", "", $letters);
		$neg = false;
		if($letters{0} == 'z') {
			$neg = true;
			$letters = substr($letters, 1);
		}
		$letters = str_replace("a", "0", $letters);
		$letters = str_replace("s", "1", $letters);
		$letters = str_replace("d", "2", $letters);
		$letters = str_replace("f", "3", $letters);
		$letters = base_convert($letters, 4, 10);
		if($neg == true) $letters = 0 - $letters;
		return (int) $letters;
	}
	function eitherway($in) {
		if(is_numeric($in)) return convertToLetters($in);
		return convertToNum($in);
	}
?>
