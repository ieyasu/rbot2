#!/usr/bin/php
<?
require_once("boilerplate.php");

if(strlen($args) == 0) {
    reply_exit(stripslashes("pong: $source $dest"));
}
$args = stripslashes($args);
$sargs = escapeshellarg($args);
$result = `ping -c 1 $sargs | grep "bytes from"`;
if(strlen($result) == 0) {
    reply_exit("ping: No reply from $args");
}
reply("ping: $result");
?>
