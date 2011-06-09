#!/bin/sh
RB_ROOT_DIR=/home/bishop/rbot-test
export RUBYLIB=$RB_ROOT_DIR/lib
cd $RB_ROOT_DIR/run
irb -r config -r rubybot2/db
