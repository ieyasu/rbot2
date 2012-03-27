#!/usr/bin/php
<?
require_once("boilerplate.php");

if(!$args) reply_exit("Reveal a tinyurl's true destination");
//if(!strstr($args, "tinyurl.com")) reply_exit("Need a tinyurl");
$args = escapeshellarg($args);
$res = `wget -O /dev/null $args 2>&1 | grep "Location"`;
$res = explode("\n", trim($res));
$l = $res[0];

if(!$l) reply_exit("Not found");
if(!preg_match("/^Location: (.*) \[following\]$/", $l, $matches)) {
    reply_exit("not found");
}
reply("Untinied: {$matches[1]}");
?>

