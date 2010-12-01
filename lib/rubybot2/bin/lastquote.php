#!/usr/bin/php
<?
	require_once("boilerplate.php");
	class first_line {
		private $currLine = null;
		private $numLines = 0;
		private $currLine_fudged = null;

		function add_line($line) {
			// if($line is earlier than $currLine, replace it
			// [mm/dd/yy hh:mm:ss]
			//if(mt_rand(0, $this->numLines) < 1) $this->currLine = $line;
			// if timestamps are the same (#linux), the first line we see is earliest
			$year = substr($line, 7, 2);
			$fline = $year . $line; // so we can just do a string compare
			if($this->currLine_fudged == null || $fline > $this->currLine_fudged) {
				$this->currLine = $line;
				$this->currLine_fudged = $fline;
			}
			$this->numLines++;
		}
		function get_line() {
			return $this->currLine;
		}
		function get_num_lines() {
			return $this->numLines;
		}
	}

	chdir("/home/sargon/log/");
	// if(preg_match("/^(\.\*)+$/", $args)) unset($args);
	if(!isset($args) || $args == "") $args = ".*";
	$N = null;
	$r = new first_line();
	if($args) {
#		$args = str_replace('"', '', $args);
#		$args = str_replace("'", '', $args);
		//$args = stripslashes($args);
//		$args = escapeshellcmd($args);
		$args = escapeshellarg($args);
		$handle = popen("pcregrep -h -i -- " . $args . " */*.log", "r");
		while(!feof($handle)) {
			$line = fgets($handle);
			if(trim($line) == "") continue;
			if(preg_match("/^[^>]+> !lastquote/", $line)) continue;
			$r->add_line($line);
		}
		pclose($handle);
		$N = $r->get_num_lines();
	} else {
		$a = opendir("/home/sargon/log/$chan");
		unset($filelist);
		while (false !== ($file = readdir($a))) {
			if(preg_match("/\.log$/", $file)) {
				if(filesize("/home/sargon/log/$chan/$file") > 1) {
					$filelist[] = $file;
				}
			}
		}
		$file = $filelist[intval(mt_rand(0, count($filelist)-2))];
		$file = "/home/sargon/log/$chan/" . $file;

#		shell_exec("cat /home/sargon/log/*.log | fgrep -v '> !quote' | fgrep -v ' quotes found: ' > $nam");
#		shell_exec("cat $file | fgrep -v '> !quote' | fgrep -v ' quotes found: ' > $nam");
		$handle = popen("fgrep -v '> !quote' $file | fgrep -v ' quotes found: '", "r");
		while(!feof($handle)) {
			$line = fgets($handle);
			if(trim($line) == "") continue;
			$r->add_line($line);
		}
		pclose($handle);
#		$N = trim(shell_exec("fgrep -v '> !quote' /home/sargon/log/$chan/*.log | fgrep -v ' quotes found: ' | wc -l"));
		$N = trim(shell_exec("wc -l */*.log | pcregrep \"total$\" | awk '{print $1}'")); // fastar
	}
		
	if($N >= 1) {
		reply("$N quotes found: " . $r->get_line());
	} else {
		reply("No matching quote found");
	}
?>

