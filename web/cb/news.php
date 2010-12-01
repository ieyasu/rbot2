<?
$a = file("http://news.google.com/news/gnmainlite.html");

if ($args == 'help') {
	print "usage: news [number of stories to pull]; first 2 stories echo to channel\n";
	exit;
}

$cnt = 1;
$limit = $args;

if ($limit < 0) $limit = 1;
if (!$args) $limit = 2;
foreach($a as $k=>$v) {
	if ($cnt > $limit) exit;
	if (strstr($v, '<a class=y h')) {
		$m = preg_match("/\<a class=y[^\>]+\>([^<]+)\<\/a\>/", $v, $mt);
		if ($m>0) { 
			if ($cnt > 2) print "*";
			print "$mt[1]\n";
#			print $mt[0];
#			print "\n";
			$cnt++;
		}
		
	}
}
