<?
function mysql_fetch_array_all($query, $base = 'none', $which = 'none') {
        $dbh = mysql_query($query);
        $i=1;
        if (!$dbh) return;
        while ($a = mysql_fetch_array($dbh, MYSQL_ASSOC)) {
                $a['%NUM%'] = $i++;
		if($base != 'none') $tmparray[$a[$base]] = $a;
			else
                $tmparray[] = $a;
        }

		if ($which != 'none' && $tmparray[$which]) {
			$tmparray[$which][SELS] = 'selected';
			$tmparray[$which][SEL] = 'selected';
			$tmparray[$which][SELC] = 'checked';
		}

        return $tmparray;
}

function mysql_query_row($query) {
	$dbh = mysql_query($query);
	return mysql_fetch_array($dbh, MYSQL_ASSOC);
}


function mqns($query, $base = 'none', $which = 'none') {
        $dbh = mysql_query($query);
        $i=1;
        if (!$dbh) return;
        while ($a = mysql_fetch_array($dbh, MYSQL_ASSOC)) {
                $a['%NUM%'] = $i++;
		if($base != 'none') $tmparray[$a[$base]] = $a;
			else
                $tmparray[] = $a;
        }

		if ($which != 'none' && $tmparray[$which]) {
			$tmparray[$which][SELS] = 'selected';
			$tmparray[$which][SEL] = 'selected';
			$tmparray[$which][SELC] = 'checked';
		}

        return $tmparray;
}

function return_to_ref() {
	global $HTTP_REFERER;
	global $newref;
	global $restoreQS;
        $parsedReferrer = parse_url($HTTP_REFERER);
        if ($newref) $referrerReturn = $newref; else
        $referrerReturn = $parsedReferrer[scheme] . "://" . $parsedReferrer[host] .  $parsedReferrer[path];

        if ($restoreQS) {
        header("Location: $referrerReturn?$qs");
        } else {
        header("Location: $referrerReturn");
        }
}

?>
