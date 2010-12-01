<?
  if(!$args)
    die("Please specify a name");

  include('inc/rodb.inc');
  $search = mysql_escape_string($args);

  $result = mysql_query("select name from monster where name = '$search'");
  if(mysql_num_rows($result) == 0)
    $result = mysql_query("select name from monster where name like '%$search%'");

  $row = mysql_fetch_row($result);

  $result = mysql_query("select monster.name, items.name from monster, drops, items where drops.monsterid = monster.id and drops.itemid = items.id and monster.name = '$row[0]' order by rate desc");
  if(mysql_num_rows($result) > 0) {
    $outstr = "$row[0] drops ";
    while($row = mysql_fetch_row($result))
      $outstr .= "$row[1], ";
    //print($outstr);
    print(substr($outstr, 0, strlen($outstr)-2));
  }
  else
    print("No match");
?>
