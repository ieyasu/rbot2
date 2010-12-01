<?
  if(!$args)
    die("Drop simulator.  Usage: kill [[number of monsters] | [until item]] <monster>");
  $argv = explode(" ", $args);
  $tillitem = "";
  if(strtolower($argv[0]) == "until")
  {
    $tillitem = $argv[1];
    array_shift($argv);
    $argv[0] = 100000;
  }
  if(is_numeric($argv[0])) {
    if($argv[0] > 100000)
      $argv[0] = 100000;
    $kills = $argv[0];
    array_shift($argv);
    $monster = implode("_", $argv);
  }
  else {
    $kills = 1;
    $monster = $args;
  }
  $a = file("monster_drops.txt");
  $const = 10000;

  foreach($a as $key => $value) {
    $value = trim($value);
    $value = str_replace('"', '', $value);
    $val = explode(',', $value);

    $mob = $val[0];
    array_shift($val);
    $drops = array();

    if(substr(strtolower($mob), 0, strlen($monster)) == strtolower($monster)) {
      $mob = strtolower($mob);
      for($k = 0; $k < $kills; $k++) {
        $cnt = count($val);
        for($j = 0; $j < $cnt; $j = $j +2) {
          $dropnum = $val[$j+1];
          $item = $val[$j];
          $rand = mt_rand(1, $const);
          if($rand <= $dropnum)
          {
            $drops[$item]['count']++;
	    if($tillitem != "") {
//              if(substr(strtolower($item), 0, strlen($tillitem)) == strtolower($tillitem)) {
              if(stristr($item, $tillitem)) {
                $kills = 0; $j = $cnt;
	      }
            }
          }
        }
      }
      $outstr = "Killed $k $mob: ";
      if(count($drops) > 0)
        foreach($drops as $dkey => $dvalue)
          $outstr .= $dkey." (".$drops[$dkey]['count']."), ";
      else
        $outstr .= "dropped nothing  ";

      print(substr($outstr, 0, strlen($outstr)-2));
      die;
    }
  }
print("Not found");
?>
