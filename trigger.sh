#!/bin/bash

# RUSSIAN ROULETTE: PULL THE TRIGGER, SHOT NOT EVERY TIME    #
# ---------------------------------------------------------- #
  SELF=`basename $0`

  if [ `ps a         | # LIST PROCESSES
        grep $SELF   | # LOOK FOR YOURSELF
        grep -v grep | # IGNORE THIS SEARCH
        wc -l` -ge 3 ]; then
        sleep 0
      # echo "STATUS: $SELF running -> exiting"
      # echo "TIME:   "`date "+%d.%m.%Y %T"`
  else  HOUR=`date +%H`
  if [ `echo $RANDOM | rev | cut -c 1` -ge 7 ] &&
     [ $HOUR -lt 24 ] && [ $HOUR -gt 5 ]; then

        PROJECTROOT=`readlink -f $0   | # ABSOLUTE PATH
                     rev              | # REVERT
                     cut -d "/" -f 2- | # REMOVE FIRST FIELD
                     rev`               # REVERT
        cd $PROJECTROOT
        SLEEPTIME=`expr $((RANDOM%3000)) \/ $((RANDOM%2+2))`
        echo "DELAY:  ${SLEEPTIME}s"
        sleep $SLEEPTIME
        echo "TIME:   "`date "+%d.%m.%Y %T"`
        TRIGGERTHIS="./tweet.sh"
        $TRIGGERTHIS
        cd - > /dev/null 2>&1
        echo
  fi
  fi

exit 0;
