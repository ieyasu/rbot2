<?
$a = explode(' ', $args);
$mod = $a[0];

array_shift($a);
$args = implode(' ', $a);

if (strstr($mod, '/')) { print "hax\n"; exit; }
if (strstr($mod, '\\')) { print "hax\n"; exit; }
if (strstr($mod, '.')) { print "hax\n"; exit; }
if (strstr($mod, 'php')) { print "hax\n"; exit; }

if (!is_file("$mod.php")) { print "file not found\n"; exit; }

include("$mod.php");
?>

