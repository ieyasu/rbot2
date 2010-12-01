<?

if (strstr($args, 'veryrecent')) {
	$veryrecent = 1;
	$args = str_replace('veryrecent ', '', $args);
}

if (strstr($args, 'recent')) {
	$recent = 1;
	$args = str_replace('recent ', '', $args);
}




if (!$args) {
print "<itemregex> [with (n slots [and <card regex>]|<card regex>]\n";
exit;
}

$wordarr['one'] = 1;
$wordarr['single'] = 1;
$wordarr['two'] = 2;
$wordarr['three'] = 3;
$wordarr['four'] = 4;

$wordarr['no'] = 0;
$wordarr[1] = 1;
$wordarr[2] = 2;
$wordarr[3] = 3;
$wordarr[4] = 4;




if (strstr($args, 'with')) {
$t = explode(' with ', $args);
$item = $t[0];
$card = $t[1];

        if (strstr($card, "slot")) {
                $card = str_replace('slots', 'slot', $card);
                $s = explode(' slot', $card);
		
		if ($s[1] && strstr($s[1], 'and')) {
			$cl2 = explode('and ', $s[1]);

			if ($cl2[1] == 'no cards' || $cl2[1] == 'no card') {
				$filter = "itemname rlike '$item' and slots = '" . $wordarr[$s[0]] . "' and cardlist = '' ";
			} else {
				$filter = "itemname rlike '$item' and slots = '" . $wordarr[$s[0]] . "' and cardlist rlike  '$cl2[1]'";
			}

		} else {
	                $filter = "itemname rlike '$item' and slots = '" . $wordarr[$s[0]] . "'";
		}
        } else {
                $filter = "itemname rlike '$item' and cardlist rlike '$card'";
        }
} else {
        $filter = "itemname rlike '$args'";
}

if ($recent) {
	$filter .= "and to_days(NOW())-to_days(time) < 5 ";
}

if ($veryrecent) {
	$filter .= "and to_days(NOW())-to_days(time) = 0 ";
}

?>
