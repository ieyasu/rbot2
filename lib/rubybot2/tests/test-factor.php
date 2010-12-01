<?
	require_once("test-framework.php");
	testMod("factor");
	assertReply("", "factor a number");
	assertReply("2", "2: 2");
	assertReply("3", "3: 3");
	assertReply("-1", "factor a number");
	assertReply("0", "0:");
	assertReply("4", "4: 2 2");
?>
