<?
	$res = `ps -aw -o '%cpu' -o user -o command | grep -v "^ 0.0" | sort -n | tail -1`;
	if(!preg_match("/^\s*(\S+)\s+(\S+)\s+(.*)$/", $res, $matches)) die("error in regex");
	if($matches[1] == "%CPU") die("Nothing using cpu");
	if(strlen($matches[3]) > 50) $matches[3] = substr($matches[3], 0, 50) . " ...";
 	print "most cpu: {$matches[1]}%, user {$matches[2]}, {$matches[3]}";
?>
