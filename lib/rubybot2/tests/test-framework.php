<?
	function testMod($mod) {
		global $modName;
		$modName = $mod;
	}
	function assertEquals($actual, $expected, $message = "unknown") {
		if($expected !== $actual) print "$message\nexpected '$expected'\nbut was  '$actual'\n";
	}
	function assertReply($input, $expected) {
		assertEquals(run($input), $expected, "Fail: for input '$input'");
	}
	function run($input) {
		global $modName;

		$input = escapeshellarg($input);
		$output = `../bin/$modName.php nick dest $input`;
		return $output;
	}
	// todo: print # of tests executed after we're done
	// todo: test suites
?>
