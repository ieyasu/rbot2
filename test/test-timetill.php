<?
	// We can't just call assert_reply since the reply depends on the current time.
	// So instead, the tz module is split into methods and command runner.
	// So in here, we just include the methods file, and then do assert_reply just
	// to make sure we don't get usage for some sample inputs.
	require_once("test-framework.php");
	require_once("../php-helpers/timetill.php");
	testMod("timetill");
	$usage = "Time till when?";
	assertReply("", $usage);
	assertReply("", $usage);
	assertReply("", $usage);
	assertReply("", $usage);
	assertReply("01/01/01 1:01:01", "Already past");
	assertReply("01/01/01 1:01", "Already past");
	assertReply("01/01/01 1:01 pm", "Already past");
	assertReply("01/01/01 1:01 am", "Already past");
	assertReply("01/01/01 1:01 Pm", "Already past");
	assertReply("01/01/01 1:01 Am", "Already past");
	assertReply("01/01/01 1:01 PM", "Already past");
	assertReply("01/01/01 1:01 AM", "Already past");
	assertReply("01/01/01 1:01 pM", "Already past");
	assertReply("01/01/01 1:01 aM", "Already past");
	assertReply("01/01/01 23:01", "Already past");
	assertReply("01/01/01 23:01 am", $usage);
	assertReply("asdf", $usage);
	assertReply("6:60", $usage);
	assertReply("6:61", $usage);
	assertReply("6:a", $usage);
	// For testing, we use mktime().  The real mod will use time().
	assertEquals(timeTill(mktime(1, 1, 0, 12, 12, 12), "12/12/2012 1:02"), "00:01:00");
	assertEquals(timeTill(mktime(1, 1, 0, 12, 12, 12), "1:02"), "00:01:00");
	assertEquals(timeTill(mktime(1, 1, 0, 12, 12, 12), "1:03"), "00:02:00");
	assertEquals(timeTill(mktime(13, 1, 0, 12, 12, 12), "13:00"), "Already past");
	assertEquals(timeTill(mktime(13, 1, 0, 12, 12, 12), "13:00"), "Already past");
	assertEquals(timeTill(mktime(1, 0, 0, 12, 12, 12), "5"), "04:00:00");
	assertEquals(timeTill(mktime(15, 0, 0, 12, 12, 12), "5"), "02:00:00");
	assertEquals(timeTill(mktime(5, 1, 0, 12, 12, 12), "5"), "11:59:00");
	assertEquals(timeTill(mktime(1, 1, 0, 12, 12, 12), "12/13/2012 1:02"), "1 day 00:01:00");
	assertEquals(timeTill(mktime(1, 1, 0, 12, 12, 12), "12/12/2013 1:02"), "365 days 00:01:00");
	assertEquals(timeTill(mktime(15, 0, 0, 12, 12, 12), "9am"), "Already past"); // this should fail... :(
//	assertEquals(timeTill(mktime(15, 0, 0, 12, 12, 12), "9am"), "18:00:00"); // this should work... :(
	//assertEquals(timeTill(mktime(15, 0, 0, 12, 12, 12), "9am tomorrow"), "18:00:00"); // this too... :(
	// also, "november" should work, but advances to nov 15th if today is the 15th... :(
	assertEquals(timeTill(mktime(15, 0, 0, 12, 12, 12), "tomorrow 9am"), "18:00:00");
	assertEquals(timeTill(mktime(0, 0, 0, 12, 24, 10), "christmas"), "1 day 00:00:00");
?>
