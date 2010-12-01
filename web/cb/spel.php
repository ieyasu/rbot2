<?
	$conf = pspell_config_create("en", "american");
	pspell_config_mode($conf, PSPELL_FAST);
	$pspell_link = pspell_new_config($conf);

	$word = $args;
	if($word == "") {
		print "Spellcheck a word\n";
		die();
	}

	if (!pspell_check($pspell_link, $word)) {
		$ret = "$word is misspelled, suggestions:";
		$suggestions = pspell_suggest($pspell_link, $word);

		foreach ($suggestions as $suggestion) {
			$ret .= " " . $suggestion;
		}
	} else {
		$ret = "$word is correct";
	}
	print $ret;

?>
