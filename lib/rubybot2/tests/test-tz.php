<?
	require_once("test-framework.php");
	testMod("tz");
	$usage = "Convert a time between time zones. Usage: !tz <time> <fromtz> [[to] totz], !tz <time> [to] <totz>";
	assertReply("", $usage);
	assertReply("01/01/10 10:00:00 US/Mountain US/Mountain", "01/01/10 10:00:00 am US/Mountain is 01/01/10 10:00:00 am US/Mountain");
	assertReply("01/01/10 10:00:00 US/Mountain to US/Mountain", "01/01/10 10:00:00 am US/Mountain is 01/01/10 10:00:00 am US/Mountain");
	assertReply("01/01/10 11:00:00 US/Mountain US/Mountain", "01/01/10 11:00:00 am US/Mountain is 01/01/10 11:00:00 am US/Mountain");
	assertReply("01/01/10 10:00:00 US/Mountain to US/Pacific", "01/01/10 10:00:00 am US/Mountain is 01/01/10 09:00:00 am US/Pacific");
	assertReply("asdf", $usage);
	assertReply("asdf asdf", $usage);
	assertReply("asdf asdf asdf", $usage);
	assertReply("asdf asdf asdf asdf", $usage);
	assertReply("asdf asdf asdf asdf asdf", $usage);
	assertReply("asdf asdf asdf asdf asdf asdf", $usage);
	assertReply(" ", $usage);
	assertReply("1", $usage);
	assertReply("asdf America/Denver to America/Denver", $usage);
	assertReply("01/01/10 10:00:00 America/Denver to", $usage);
	assertReply("01/01/10 10:00:00 America/Denver to America/Denver to", $usage);
	assertReply("01/01/10 10:00:00 Mountain to Mountain", "01/01/10 10:00:00 am US/Mountain is 01/01/10 10:00:00 am US/Mountain");
	assertReply("01/01/10 10:00:00 Denver to Denver", "01/01/10 10:00:00 am America/Denver is 01/01/10 10:00:00 am America/Denver");
	assertReply("01/01/10 10:00 Mountain to Mountain", "01/01/10 10:00:00 am US/Mountain is 01/01/10 10:00:00 am US/Mountain");
	assertReply("01/01/10 10:00 Pacific", "01/01/10 10:00:00 am US/Pacific is 01/01/10 11:00:00 am America/Denver");
	assertReply("01/01/10 10:00 to Pacific", "01/01/10 10:00:00 am America/Denver is 01/01/10 09:00:00 am US/Pacific");
	assertReply("01/01/10 10:00 mountain to mountain", "01/01/10 10:00:00 am US/Mountain is 01/01/10 10:00:00 am US/Mountain");
	assertReply("01/01/10 10:00 mOuntain to mOuntain", "01/01/10 10:00:00 am US/Mountain is 01/01/10 10:00:00 am US/Mountain");
	assertReply("01/01/10 10:00 MOUNTAIN to MOUNTAIN", "01/01/10 10:00:00 am US/Mountain is 01/01/10 10:00:00 am US/Mountain");
	assertReply("01/01/10 10:00 mst to pst", "01/01/10 10:00:00 am MST is 01/01/10 09:00:00 am pst");
	assertReply("01/01/10 10:00 mSt to pSt", "01/01/10 10:00:00 am MST is 01/01/10 09:00:00 am pSt");
	assertReply("01/01/10 10:00 MST to PST", "01/01/10 10:00:00 am MST is 01/01/10 09:00:00 am PST");
	assertReply("01/01/10 10:00 mountain to europe/berlin", "01/01/10 10:00:00 am US/Mountain is 01/01/10 06:00:00 pm Europe/Berlin");
	assertReply("01/01/10 10:00 mountain to berlin", "01/01/10 10:00:00 am US/Mountain is 01/01/10 06:00:00 pm Europe/Berlin");
	assertReply("America to America", $usage);
	// MST, MDT, UTC, GMT
	// "10 am"
	// 10:00
?>
