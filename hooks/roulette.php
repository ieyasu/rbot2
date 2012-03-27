#!/usr/bin/php
<?
require_once("boilerplate.php");

if(trim($args) == "gimmetengrand") {
    db("delete from roulette where id = '$source'");
    db("insert into roulette values('$source', '10000')");
    reply_exit("ok, you have 10000");
}

$args = str_replace("$", "", $args);
$args = str_replace(" on ", ";", $args);
$stuff = explode(";", $args);

$betamount = trim($stuff[0]);
$bet = trim($stuff[1]);
$nick = $source;

$a = db("select * from roulette where id = '$nick'");
if($a) {
    $money = $a[0][money];
} else {
    $money = 1;
}
if($betamount > $money) reply_exit('You only have $' . $money);
if($betamount != intval($betamount)) reply_exit("can't parse bet amount $betamount");
if($betamount < 0) reply_exit("Can't parse bet amount $betamount");

$wins = array();

if($bet == "red") {
    $wins = array(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36);
    $win = ($betamount * 2) - $betamount;
}

else 	if($bet == "black") {
    $wins = array(2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35);
    $win = ($betamount * 2) - $betamount;
}

else 	if($bet == "even" || $bet == "evens") {
    $wins = array(2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36);
    $win = ($betamount * 2) - $betamount;
}

else 	if($bet == "odd" || $bet == "odds") {
    $wins = array(1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35);
    $win = ($betamount * 2) - $betamount;
}

else 	if($bet === "00" || $bet == "double zero") {
    $wins = array(38);
    $win = ($betamount * 36) - $betamount;
}

else 	if($bet === "0" || $bet == "zero" || $bet == "single zero") {
    $wins = array(37);
    $win = ($betamount * 36) - $betamount;
}

// keep me last
else 	if(intval($bet) > 0 && intval($bet) < 37) {
    $wins = array(intval($bet));
    $win = ($betamount * 36) - $betamount;
}

else	{
	if($betamount != 0) reply_exit("Can't parse bet $bet");
}

$val = mt_rand(1,38);
$list = array( 1=>'1 red',
               '2 black',
               '3 red',
               '4 black',
               '5 red',
               '6 black',
               '7 red',
               '8 black',
               '9 red',
               '10 black',
               '11 black',
               '12 red',
               '13 black',
               '14 red',
               '15 black',
               '16 red',
               '17 black',
               '18 red',
               '19 red',
               '20 black',
               '21 red',
               '22 black',
               '23 red',
               '24 black',
               '25 red',
               '26 black',
               '27 red',
               '28 black',
               '29 black',
               '30 red',
               '31 black',
               '32 red',
               '33 black',
               '34 red',
               '35 black',
               '36 red',
               'single zero',
               'double zero' );
$s = '';
if($betamount != 0) {
    $s = $s . "$list[$val]: ";
    if(in_array($val, $wins)) {
        $money += $win;
        $s = $s . 'you win $' . $win;
        $s = $s . ', you have $' . $money;
    } else {
        $money -= $betamount;
        if($money == 0) $money = 1;
        $s = $s . 'you lose $' . $betamount;
        $s = $s . ', you have $' . $money;
    }
    db("delete from roulette where id = '$nick'");
    db("insert into roulette values('$nick', '$money')");
} else {
    $s = $s . "$list[$val], you have " . '$' . $money;
}
//if($betamount != 0) mysql_query("delete from roulette where id = '$nick'");
db("delete from roulette where money <= 1");

reply($s);
?>
