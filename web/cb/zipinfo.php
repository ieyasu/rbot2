<?
if (!$args) {
	$self = basename($PHP_SELF, ".php");
	print "usage: $self zipcode\n";
	exit;
}

require_once("SOAP/Client.php");
$w = new SOAP_WSDL("wsdl/zipinfo.wsdl");
$w = $w->getProxy();
$a = $w->ZipCodes($args);
print implode(', ', $a);
?>
