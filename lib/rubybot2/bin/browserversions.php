#!/usr/bin/php
<?
	require_once("boilerplate.php");
	$data = file("http://marketshare.hitslink.com/report.aspx?qprid=2&qptimeframe=M&qpsp=131&qpmr=40&qpdt=1&qpct=3&qpf=13");
	$drop = true;
	$xml = "";
	foreach($data as $line) {
		if(preg_match("/^<\?xml/i", $line)) {
			$drop = false;
		}
		if($drop == false) {
			$xml = $xml . $line;
		}
	}
	$xml = new SimpleXmlElement($xml);
	$output = "";
	foreach($xml->reportdata->dataset->row as $row) {
		$b = $row->value1;
		$b = str_replace("Microsoft Internet Explorer", "IE", $b);
		$b = str_replace("Firefox", "FF", $b);
		$str = $b . ": " . $row->value2;
		if($output == "") $n = $str;
		else $n = $output . "; " . $str;
		if(strlen($n) < 250) $output = $n;
		else break;
	}
	reply($output);
?>
