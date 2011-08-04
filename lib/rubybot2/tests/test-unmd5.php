<?
	require_once("test-framework.php");
	testMod("unmd5");
	assertReply("", "Give me an MD5 string and I'll try to reverse it");
	assertReply("asdf", "Not found");
	assertReply("912ec803b2ce49e4a541068d495ab570", "asdf");
?>
