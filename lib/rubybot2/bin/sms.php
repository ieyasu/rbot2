#!/usr/bin/php
<?php

require_once("boilerplate.php");
require_once("php-helpers/twilio.php");

// Parse arguments
$sms_args = preg_split("/\s+/", $args, 2);
if (count($sms_args) != 2) {
	reply("Usage: sms <name> <message>");
	exit;
}

$target = $sms_args[0];
$message = "<$nick> ".$sms_args[1];

// Find target phone number
$data = db("select number from sms where nick=\"$target\"");
if (!isset($data[0]['number'])) {
	reply("Number not found for nick $target");
	exit;
} else {
	$number = $data[0]['number'];
}

// Twilio settings
$ApiVersion = "2010-04-01";
$AccountSid = "AC87725ff15944938d0dd09796b0fe64d8";
$AuthToken = "ddccfc7ba33cbc66246438df18ed04b0";
$TwilioNumber = "970-818-0651";

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
