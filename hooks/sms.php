#!/usr/bin/php
<?php

require_once("inc/sms_auth.inc");
require_once("boilerplate.php");
require_once("php-helpers/twilio.php");

// Parse arguments
$sms_args = preg_split("/\s+/", $args, 2);
if (count($sms_args) != 2) {
	reply("Usage: sms <name> <message>");
	exit;
}

$target = $sms_args[0];
$message = "From $nick: " . $sms_args[1] . " DO NOT REPLY DIRECTLY";

// Find target phone number
$data = db("select number from sms where nick=\"$target\"");
if (!isset($data[0]['number'])) {
	reply("Number not found for nick $target");
	exit;
} else {
	$number = $data[0]['number'];
}

// Send the SMS using REST
$client = new TwilioRestClient($AccountSid, $AuthToken);
$response = $client->request("/$ApiVersion/Accounts/$AccountSid/SMS/Messages", 
	"POST", array(
		"To" => $number,
		"From" => $TwilioNumber,
		"Body" => $message
));
if($response->IsError) {
	reply("Error: {$response->ErrorMessage}");
} else {
	reply("Sent message to $target");
}
?>
