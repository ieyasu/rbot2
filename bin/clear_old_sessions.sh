#!/bin/bash

. `dirname $BASH_SOURCE`/ENVIRONMENT
cd $RB_ROOT

now=`date +%s`
sql="DELETE FROM sessions WHERE expires_at < $now;"
sqlite3 db/rubybot.db "$sql"
