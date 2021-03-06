#!/bin/bash

# RUSSIAN ROULETTE: PULL THE TRIGGER, SHOT NOT EVERY TIME    #
# ---------------------------------------------------------- #
  SELF=`basename $0`
  HOUR=`date +%H`
  if [ `echo $RANDOM | rev | cut -c 1` -ge 8 ] &&
     [ $HOUR -lt 21 ] && [ $HOUR -gt 7 ]; then

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
        SLEEPTIME=`expr $((RANDOM%7500)) \/ $((RANDOM%30+1))`
        echo "--------------------------"
        echo "TIME: "`date "+%d.%m.%Y %H:%M:%S"`
        echo "WAIT: ${SLEEPTIME}s"
        sleep $SLEEPTIME
        echo "--------------------------"
        TRIGGERTHIS="./tweet.sh"
        $TRIGGERTHIS
        cd - > /dev/null 2>&1
        echo
  fi

exit 0;
