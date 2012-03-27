<?
	require_once("test-framework.php");
	testMod("unmd5");
	assertReply("", "Give me an MD5 string and I'll try to reverse it");
	assertReply("asdf", "Not found");
	assertReply("912ec803b2ce49e4a541068d495ab570", "asdf");
	assertReply("9e7fddb717d700ebc4a48c6638bb65c3", "unmd5");
	assertReply("a5797b5baed83b07283d85302acc491f", "Not found");
?>
