<?
	mysql_pconnect("localhost", "ircuser", "01230");
	mysql_selectdb("IRC");

	function db($query) {
		$ret = array();
		$res = mysql_query($query);
		if($res === true) return;
		if($res === false) return mysql_error();
		while($row = mysql_fetch_assoc($res)) {
			$ret[] = $row;
		}
		return $ret;
	}
?>
