<?
// blue's !shoot module
// takes a target name as an argument and echo's a shot in the channel

if(!$args)
    die("To make rb love someone: !love <person>.");

$shotsfile = "res/loves.txt";

// no one seems to realize how dumb it looks when a full phrase gets
// substituted in place of a person's name.
$args = preg_replace('/(for|beca(use|ues)).*$/','',$args);
$args = trim($args);
if ($args == '')
//  die("oh please, that doesn't even make sense!");
  $args = $source;

$fp = @fopen($shotsfile, "r");
  if(!$fp) die("cannot access shots.txt");
  $src = fread($fp, filesize($shotsfile));
  fclose($fp);

  $lines = explode("\n", $src);
//$lines is an array
  $qnum = rand(0, count($lines)-2);

#  if(substr($lines[$qnum], 0, 1) == "*")
#    $lines[$qnum] = " ".$lines[$qnum];

	$shot = $lines[$qnum];

	$static = array("\$source", "\$args");
	$session = array($source, $args);
	$outputargs = str_replace($static, $session, $shot);
	print stripslashes("\001ACTION " . $outputargs );

?>
