<?
require('inc/rodb.inc');


$a = mqns("select * from items where name regexp '$args' or prefix 
regexp '$args'");

if (!$a) {
print "no info\n";
exit;
}

print $a[0][name] . " (" . $a[0][price] . "z) " . " : " . $a[0][descr] . " :" . $a[0][prefix];
print "\n";



?>
