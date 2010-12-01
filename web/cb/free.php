<?
	print trim(`df -h /dev/ad4s1f | grep ad4s1f | awk '{print $4}'`) . " free";
?>
