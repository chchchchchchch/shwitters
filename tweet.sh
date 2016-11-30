#!/bin/bash

# TODO: support https for shourl
# -t = TEST

# --------------------------------------------------------------------------- #
# FIRST THINGS FIRST
# --------------------------------------------------------------------------- #
  source lib/sh/twitter.functions
  source lib/sh/shourls.functions
# --------------------------------------------------------------------------- #
# STILL SETTING UP 
# --------------------------------------------------------------------------- #
  SRCDIR="_"
  TMPDIR="."
     TMP=$TMPDIR/tmp
  LOG="/dev/null"
  URLFOO="XXXXXXXXXXXXXXXXXXXXXXXX"  # 24 CHARS FOR AN URL
  IMGFOO="XXXXXXXXXXXXXXXXXXXXXXXX"  # 24 CHARS FOR AN IMAGE
  COMPOSE=${TMP}.txt
# --------------------------------------------------------------------------- #
# CHECK PARAMETERS
# --------------------------------------------------------------------------- #
  MESSAGE=`echo $* | sed 's/-t//g' | sed 's/ //g'`
  if [ `echo "$MESSAGE" | wc -c` -lt 1 ];
     [ ! -f  "$MESSAGE" ]
   then echo "No input file provided!"
        MESSAGE=`find $SRCDIR -name "*.tweet" | shuf -n 1`
        if [ `echo $MESSAGE | wc -c` -gt 1 ]; then
              echo "USE $MESSAGE"
        else  echo "NOTHING TO DO."; exit 0; fi
  else  echo "USE $MESSAGE"; fi

# --------------------------------------------------------------------------- #
# COMPOSE MESSAGE (WITH MEDIA FOR COUNTING)
# --------------------------------------------------------------------------- #
  cat $MESSAGE             | #
  grep -v "^%"             | #
  sed 's/^[ \t]*//'        | #
  sed ':a;N;$!ba;s/\n/ /g' | #
  tr -s ' '                | # SQUEEZE SPACES
  tee > $COMPOSE             # WRITE TO FILE (TMP)
# --------------------------------------------------------------------------- #
# CHECK MESSAGE
# --------------------------------------------------------------------------- #
  CHARCNT=`cat $COMPOSE                       | # 
           sed "s, http://[^ $]*,$URLFOO,g"   | #
           sed "s, [0-9a-zA-Z\.]*/.*\.svg[ $]\?,$IMGFOO,g" | #
           wc -c`; # echo $CHARCNT
  if [ `echo $* | grep -- "-t" | wc -l ` -gt 0 ]; then
        echo "Character count: $CHARCNT"
        exit 0;
  fi; if [ $CHARCNT -gt 141 ]; then echo "TOO MANY CHARS"; exit 0; fi
# --------------------------------------------------------------------------- #
# REMOVE MEDIA (UPLOAD HANDLED SEPARATELY)
# --------------------------------------------------------------------------- #
  sed -i "s, [0-9a-zA-Z\.]*/.*\.svg[ $]\?, ,g" $COMPOSE
# --------------------------------------------------------------------------- #
# SHORTEN URLS
# --------------------------------------------------------------------------- #
  for URL in `cat $MESSAGE   | #
              grep "^http"   | #
              sed "s/ /\n/g" | #
              grep "http://" | #
              sort -u`
   do
      URL=`echo $URL | sed 's/[.!?]*$//'`
      C1=1;C2=6
      URLHASH=`echo $URL | md5sum | #
               cut -d " " -f 1 | sed 's/[^0-9]//g'`
      SHOURL=`echo $URLHASH | cut -c $C1-$C2`
      shourlsGetInfo "$SHOURL"                            >> $LOG
     #echo "$SHOURL $REMOTELONGURL ($STATUS)"

    while [ "S=$STATUS" != "S=404" ] &&
          [ "U=$URL" != "U=$REMOTELONGURL" ]; do
             C1=`expr $C1 + 1`
             C2=`expr $C2 + 1`
             SHOURL=`echo $URLHASH | cut -c $C1-$C2`
             shourlsGetInfo "$SHOURL"                     >> $LOG
           # echo "$SHOURL $REMOTELONGURL ($STATUS)"
    done
         SHOURLTITLE="$URL"
         echo "$SHOURL -> $URL"
       # UPDATE URL
         shourlsMakeEntry "$URL" "$SHOURL" "$SHOURLTITLE" >> $LOG
       # INSERT SHORT URL
         sed -i "s,$URL,lfkn.de\/$SHOURL,g" $COMPOSE
   done
# --------------------------------------------------------------------------- #
# PROCESS MEDIA (KEEP ONLY LAST MEDIA ENTRY)
# --------------------------------------------------------------------------- #
  for MEDIA in `cat $MESSAGE | #
                grep ".*/.*\.svg$" | #
                tail -n 1`
   do
      MESSAGEPATH=`echo $MESSAGE | rev | #
                   cut -d "/" -f 2- | rev`
      MEDIA=$MESSAGEPATH/$MEDIA
      if [ -f $MEDIA ]; then
      MEDIAUPLOAD=${TMP}.png
      inkscape --export-png=${MEDIAUPLOAD} $MEDIA > /dev/null 2>&1
      fi
  done

# --------------------------------------------------------------------------- #
# HAU RAUS DAT DINGEN
# --------------------------------------------------------------------------- #
  TIMESTAMP=`date +%y%m%d%H%M`
  tweet `cat $COMPOSE` $MEDIAUPLOAD

# --------------------------------------------------------------------------- #
# DISABLE .tweet WHEN DONE
# --------------------------------------------------------------------------- #
  mv $MESSAGE `echo $MESSAGE | sed 's/\.tweet$//'`.$TIMESTAMP

# --------------------------------------------------------------------------- #
# CLEAN UP
# --------------------------------------------------------------------------- #
  if [ -f ${TMP}.png ]; then rm ${TMP}.png ; fi
  if [ -f ${TMP}.txt ]; then rm ${TMP}.txt ; fi


exit 0;
