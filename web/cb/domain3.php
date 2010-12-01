<?php

if (!$args) {
	print "syntax: domain <domain name>";
	exit;
}

$xml = new SoapClient("http://www.webservicex.net/whois.asmx?wsdl");

print($xml->GetWhoIS($args));

?>
