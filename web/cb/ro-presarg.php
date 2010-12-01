<?
  if(!$args)
    die("RO Module.  !ro <monster> or !ro [stats|extended|drops|location] <monster>.  All submodules have usage instructions.");

  $arg = explode(" ", $args);

  @$fp = fopen("res/monster.csv", "r");
  if(!$fp) die("res/monster.csv missing or corrupt");
  $src = fread($fp, 80000);
  fclose($fp);
  
  $cmd = trim(strtolower($arg[0]));
  if($cmd == "drops") {
    if(!$arg[1])
      die("Shows dropped items and probabilities.  Usage: !ro drops <monster>");
    $query = trim($arg[1]." ".$arg[2]);
  }
  elseif($cmd == "location") {
    if(!$arg[1])
      die("Shows where the monster can be found.  Usage: !ro location <monster>");
    $query = trim($arg[1]." ".$arg[2]);
  }
  elseif($cmd == "extended") {
    if(!$arg[1])
      die("Shows extended monster information.  Usage: !ro extended <monster>");
    $query = trim($arg[1]." ".$arg[2]);
  }
  elseif($cmd == "stats") {
    if(!$arg[1])
      die("Usage: !ro [stats] <monster>.  Flags are Aggressive, Loots, Detects, aSsists, Boss, Miniboss, slasH damage, Immobile, Passive, Ranged attack");
    $query = trim($arg[1]." ".$arg[2]);
  }
  else {
    $query = $args;
  }

  $lines = explode("\n", $src);
  foreach($lines as $line) {
    $row = explode(";", $line);
    if(strtolower(trim($row[0])) == strtolower(trim($query))) {
      $found = 1;
      $arr = $row;
      break;
    }
  }

  if(!$found) {
    foreach($lines as $line) {
      $row = explode(";", $line);
      if(stristr($row[0], $query)) {
        $found = 1;
        $arr = $row;
        break;
      }
    }
  }

  if($found) {
    if($cmd == "drops")
      $outstr = "$row[0]- $row[18]";
    elseif($cmd == "location")
      $outstr = "$row[0]- $row[19]";
    elseif($cmd == "extended")
      $outstr = "$row[0]- Lv: $arr[3]  agi: $arr[10]  dex: $arr[11]  str: $arr[12]  vit: $arr[13]  int: $arr[14]  luk: $arr[15]";
    else
      $outstr = "$arr[0]- $arr[1] HP: $arr[2]  ATK: $arr[9]  Def/md: $arr[16]/$arr[17]  XP/Job: $arr[4]/$arr[5]  ($arr[8]/$arr[7]/$arr[6])";
    die($outstr);
  }

  die("Not found");
?>
