<?
$ar = explode(' ', $args);
if (!($ar[0] && $ar[1])) {
	$self = basename($PHP_SELF, ".php");
	print "returns distance between two zip codes Usage: $self zipFrom zipTo\n";
	exit;
}

require_once("SOAP/Client.php");
$w = new SOAP_WSDL("wsdl/ZipDistance.wsdl");
$w = $w->getProxy();
$a = number_format($w->getDistance($ar[0], $ar[1]), 2);

print "Distance is $a\n";
?>
