#!/usr/bin/php
<?
	require_once("boilerplate.php");

	# Source: http://www.kilgarriff.co.uk/bnc-readme.html

	# sort-order, frequency, word, word-class

	#conj (conjunction)            34 items
	#adv  (adverb)                427
	#v    (verb)                 1281
	#det  (determiner)             47
	#pron (pronoun)                46
	#interjection                  13
	#a    (adjective)            1124
	#n    (noun)                 3262
	#prep (preposition)            71
	#modal                         12
	#infinitive-marker              1

	if(!$args) {
		reply('Parts of speech: $conjunction $adverb $verb $determiner $pronoun $interjection $adjective $noun $preposition $modal $infinitive-marker $letter $digit $color $month');
		exit();
	}

	$args = stripslashes($args);

	reply(get_madlib($args));

	function get_madlib($str) {
		$str = replace_word($str, 'conjunction', 'conj');
		$str = replace_word($str, 'adverb', 'adv');
		$str = replace_word($str, 'verb', 'v');
		$str = replace_word($str, 'determiner', 'det');
		$str = replace_word($str, 'pronoun', 'pron');
		$str = replace_word($str, 'interjection', 'interjection');
		$str = replace_word($str, 'adjective', 'a');
		$str = replace_word($str, 'noun', 'n');
		$str = replace_word($str, 'preposition', 'prep');
		$str = replace_word($str, 'modal', 'modal');
		$str = replace_word($str, 'infinitive-marker', 'infinitive-marker');
		$str = replace_word($str, 'letter', 'letter');
		$str = replace_word($str, 'color', 'color');
		$str = replace_word($str, 'month', 'month');
		$str = replace_word($str, 'digit', 'digit');
		$str = replace_word($str, 'number', 'number');
		return $str;
	}

	function replace_word($str, $word, $part) {
		$word = strtolower($word);
		$regex = '/\$' . $word . '/';
		$str = replace_word_lc($str, $regex, $part);
		$word = ucfirst($word);
		$regex = '/\$' . $word . '/';
		$str = replace_word_ucfirst($str, $regex, $part);
		$word = strtoupper($word);
		$regex = '/\$' . $word . '/';
		$str = replace_word_uc($str, $regex, $part);
		return $str;
	}

	function replace_word_lc($str, $word_regex, $part) {
		while(preg_match($word_regex, $str)) {
			$str = preg_replace($word_regex, get_word($part), $str, 1);
		}
		return $str;
	}

	function replace_word_uc($str, $word_regex, $part) {
		while(preg_match($word_regex, $str)) {
			$str = preg_replace($word_regex, strtoupper(get_word($part)), $str, 1);
		}
		return $str;
	}

	function replace_word_ucfirst($str, $word_regex, $part) {
		while(preg_match($word_regex, $str)) {
			$str = preg_replace($word_regex, ucfirst(get_word($part)), $str, 1);
		}
		return $str;
	}

	function get_word($pos) {
		if($pos == 'number') return get_number();
		static $words;
		if(!$words) {
			$file = file("db/lemma.al");

			$words = array();
			foreach($file as $line) {
				$line = trim($line);
				$parts = explode(" ", $line);
				if(!isset($words[$parts[3]])) $words[$parts[3]] = array();
				$words[$parts[3]][] = $parts[2];
			}
			$words['letter'] = range("a", "z");
			$words['digit'] = range(0, 9);
			$words['color'] = get_colors();
			$words['month'] = array("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december");
		}
		$pos = strtolower($pos);

		$size = count($words[$pos]);
		$rand = (int) mt_rand(0, $size-1);
		return $words[$pos][$rand];
	}

	function get_number() {
		$ret = "";
		$digits = mt_rand(1, 10);
		for($i=0;$i<$digits;$i++) {
			$ret .= mt_rand(0,9);
		}
		return $ret;
	}

	function get_colors() {
		$file = file("db/colors.txt");
		$ret = array();
		foreach($file as $line) {
			$ret[] = strtolower(trim($line));
		}
		return $ret;
	}
?>
