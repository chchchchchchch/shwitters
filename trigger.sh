#!/bin/bash

# RUSSIAN ROULETTE: PULL THE TRIGGER, SHOT NOT EVERY TIME    #
# ---------------------------------------------------------- #
  SELF=`basename $0`
  HOUR=`date +%H`
  if [ `echo $RANDOM | rev | cut -c 1` -ge 7 ] &&
     [ $HOUR -lt 24 ] && [ $HOUR -gt 5 ]; then

  if [ `ps a         | # LIST PROCESSES
        grep $SELF   | # LOOK FOR YOURSELF
        grep -v grep | # IGNORE THIS SEARCH
        wc -l` -ge 3 ]; then
        ALREADY=`ps a         | #
                 grep $SELF   | #
                 grep -v grep`
        echo -e "STATUS: running -> exiting \n$ALREADY"
        echo    "TIME:   "`date "+%d.%m.%Y %T"`
        exit 0;
  fi
        PROJECTROOT=`readlink -f $0   | # ABSOLUTE PATH
                     rev              | # REVERT
                     cut -d "/" -f 2- | # REMOVE FIRST FIELD
                     rev`               # REVERT
        cd $PROJECTROOT
        SLEEPTIME=`expr $((RANDOM%2500)) \/ $((RANDOM%2+2))`
        echo "DELAY:  ${SLEEPTIME}s"
        sleep $SLEEPTIME
        echo "TIME:   "`date "+%d.%m.%Y %T"`
        TRIGGERTHIS="./tweet.sh"
        $TRIGGERTHIS
        cd - > /dev/null 2>&1
        echo
  fi

exit 0;
