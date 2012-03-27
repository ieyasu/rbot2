<?
	require_once("test-framework.php");
	testMod("rot13");
	assertReply("a", "n");
	assertReply("asdf", "nfqs");
	assertReply("", "rot13 something");
?>
