<?     
      $name = "";
      $realm = "Lordaeron";
      $game = "tft";

      $stuffins = split(":", $args, 3);
      $name = $stuffins[0];
  
      if ($name == "") {
         print "Usage: !bnet <name>[:realm[:classic]]";
         exit;
      }      

      if (isset($stuffins[1])) $realm = $stuffins[1];
      if (isset($stuffins[2])) $game = $stuffins[2];

      $name = urlencode($name);
      $realm = urlencode($realm);
      
      if ($game == "tft")
         $url = "http://www.battle.net/war3/ladder/W3XP-player-profile.aspx?Gateway=$realm&PlayerName=$name";
      else
         $url = "http://www.battle.net/war3/ladder/war3-player-profile.aspx?Gateway=$realm&PlayerName=$name";
      $raw = "";
      $err = "";
      
      $file = fopen ($url, "r");
      if($file) {
         while (!feof ($file)) {
            $raw .= fgets ($file, 1024);
         }
      } else {
         $err = "Error connecting to battle.net";
      }
      fclose($file);
      
      // Now that we have the raw page, find where it gives the ID of the first result
      preg_match("/<b class=\"small\">Level\s+(\d+)<\/b><\/div>/m", $raw, $matches);
      
      if (isset($matches[1])) $level = $matches[1];
      
      # Getting wins/losses
      preg_match("/<td align=\"right\" valign=\"top\" class=\"rankingHeader\">Total:<\/td>\s+<td align=\"middle\" valign=\"top\" class=\"rankingRow\">(\d*)<\/td>\s+<td align=\"middle\" valign=\"top\" class=\"rankingRow\">(\d*)<\/td>/m", $raw, $matches);


      $wins = $matches[1];
      $losses = $matches[2];
      if ($losses == 0) $pct = "100";
      else $pct = round(100 * ($wins / ($wins + $losses)));
      $pct .= "%";
      

      #Check to see if they weren't found...
      preg_match("/(<span class='colorRed'>Player Not Found!<\/span>)/m", $raw, $matches);
      if (isset($matches[1])) $err = "Player Not Found!";
      
      if ($err) {
         print "$err\n";
      } else {
	print "$name (Level $level) $wins/$losses ($pct)  Profile: $url\n";
      }

?>
