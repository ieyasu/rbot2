<?
  if(!$args)
    die("Please specify a name");

  include('inc/rodb.inc');
  $search = mysql_escape_string($args);

  $result = mysql_query("select name from items where name = '$search'");
  if(mysql_num_rows($result) == 0)
    $result = mysql_query("select name from items where name like '%$search%'");

  $row = mysql_fetch_row($result);

  $result = mysql_query("select items.name, monster.name from monster, drops, items where drops.monsterid = monster.id and drops.itemid = items.id and items.name = '$row[0]' order by rate desc");
  if(mysql_num_rows($result) > 0) {
    $outstr = "$row[0] is dropped by ";
    while($row = mysql_fetch_row($result))
      $outstr .= "$row[1], ";
    print(substr($outstr, 0, strlen($outstr)-2));
    //print($outstr);
  }
  else
    print("No match");
?>
