<?
die("this module is broken.  maintainer: unknown");

if (!$args) {
	$self = basename($PHP_SELF, '.php');
	print "Usage: $self ip\n";
	exit;
}

require_once("SOAP/Client.php");
$w = new SOAP_WSDL("wsdl/geoipservice.wsdl");
$w = $w->getProxy();
$a = $w->getgeoip($args);
if ($a->ReturnCode < 0) {
	print "IP: {$a->IP}, {$a->ReturnCodeDetails}\n";
	exit;
}
print "IP: {$a->IP}, CountryCode: {$a->CountryCode}, CountryName: {$a->CountryName}\n";
?>
