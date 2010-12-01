<?
if (!$args) {
	$self = basename($PHP_SELF, ".php");
	print "get atomic weight, symbol and number for an element: Usage: $self element\n";
	exit;
}

require_once("SOAP/Client.php");
$w = new SOAP_WSDL("wsdl/periodictable.wsdl");
$w = $w->getProxy();


$info = $w->GetAtomicNumber($args);
preg_match("/<AtomicWeight>([^<]+)</AtomicWeight>/", $info, $weight);
preg_match("/<Symbol>([^<]+)</Symbol>/", $info, $symbol);



?>
