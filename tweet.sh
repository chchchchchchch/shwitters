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
  IMGFOO="XXXXXXXXXXXXXXXXXXXXXXXX"  # 26 CHARS FOR AN IMAGE
  COMPOSE=${TMP}.txt
# --------------------------------------------------------------------------- #
# CHECK PARAMETERS
# --------------------------------------------------------------------------- #
  MESSAGE=`echo $* | sed 's/-t//g' | sed 's/ //g'`

  if [ `echo "$MESSAGE" | wc -c` -lt 1 ];
     [ ! -f  "$MESSAGE" ]
   then echo "No input file provided!"
        MESSAGE=`ls $SRCDIR/*.tweet | shuf -n 1`
        echo "Use $MESSAGE"
  else
        echo "Use $MESSAGE"
  fi
# --------------------------------------------------------------------------- #
# COMPOSE MESSAGE (WITH E/MEDIA FOR COUNTING)
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
           sed "s, E/.*\.svg[ $]\?,$IMGFOO,g" | #
           wc -c`; # echo $CHARCNT
  if [ `echo $* | grep -- "-t" | wc -l ` -gt 0 ]; then
        echo "Character count: $CHARCNT"
        exit 0;
  fi

# TODO: STOP IF TOO MANY CHARACTERS (142)

# --------------------------------------------------------------------------- #
# REMOVE E/MEDIA (UPLOAD HANDLED SEPARATELY)
# --------------------------------------------------------------------------- #
  sed -i "s, E/.*\.svg[ $]\?,,g" $COMPOSE

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
                grep "^E/.*\.svg$" | #
                tail -n 1`
   do
      MEDIAUPLOAD=${TMP}.png
      inkscape --export-png=${MEDIAUPLOAD} $MEDIA > /dev/null 2>&1
  done

# --------------------------------------------------------------------------- #
# HAU RAUS DAT DINGEN
# --------------------------------------------------------------------------- #
  tweet `cat $COMPOSE` $MEDIAUPLOAD

# --------------------------------------------------------------------------- #
# CLEAN UP
# --------------------------------------------------------------------------- #
  if [ -f ${TMP}.png ]; then rm ${TMP}.png ; fi
  if [ -f ${TMP}.txt ]; then rm ${TMP}.txt ; fi




exit 0;
