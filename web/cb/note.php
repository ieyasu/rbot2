<?
require('inc/cbotdb.inc');
/*
+-------+--------------+------+-----+---------+----------------+
| Field | Type         | Null | Key | Default | Extra          |
+-------+--------------+------+-----+---------+----------------+
| id    | int(11)      |      | PRI | NULL    | auto_increment |
| nick  | varchar(255) | YES  |     | NULL    |                |
| note  | text         | YES  |     | NULL    |                |
| date  | datetime     | YES  |     | NULL    |                |
+-------+--------------+------+-----+---------+----------------+
*/

if ($args) {
	$note = mysql_escape_string($args);
	@mqns("insert into notes (nick, note, date) values ('$source', '$note', NOW())");
	print "Note Recorded!";
	print "\n";
}

?>
