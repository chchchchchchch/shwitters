#!/bin/bash

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
  LOG="/dev/stdout"
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
        for L in `find $SRCDIR -name "*.list"`; do 
          for M in `cat $L | grep -v "^%"`; do
              MESSAGE="$MESSAGE|"`find $SRCDIR -name "$M"`
        done;done
        MESSAGE=`echo $MESSAGE | sed 's/|/\n/g' | #
                 sed '/^|*$/d' | shuf -n 1`
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
  CHARCNT=`cat $COMPOSE | # USELESS USE OF CAT
           sed "s, http://[^ $]*,$URLFOO,g" | # URL COUNT
           sed "s, [0-9a-zA-Z\.]*/.*\.svg[ $]\?,$IMGFOO,g" | # IMG COUNT
           sed "s,[ \t]*%NL[ \t]*,XX,g"  | # NEWLINE COUNT
           sed 's/./X/g' | # MAKE EVERY CHAR 1 (UNICODE CHAR MISCOUNT?)
           wc -c`; # echo $CHARCNT
  if [ `echo $* | grep -- "-t" | wc -l ` -gt 0 ]; then
        echo "Character count: $CHARCNT"
        exit 0;
  fi;  if [ $CHARCNT -gt 141 ]; then echo "TOO MANY CHARS"; exit 0; fi

# --------------------------------------------------------------------------- #
# REMOVE MEDIA (UPLOAD HANDLED SEPARATELY)
# --------------------------------------------------------------------------- #
  sed -i "s, [0-9a-zA-Z\.]*/.*\.svg[ $]\?, ,g" $COMPOSE
# --------------------------------------------------------------------------- #
# MAKE NEWLINES
# --------------------------------------------------------------------------- #
  sed -i "s,[ \t]*%NL[ \t]*,%0a,g" $COMPOSE
# --------------------------------------------------------------------------- #
# SHORTEN URLS
# --------------------------------------------------------------------------- #
  for URL in `cat $MESSAGE      | #
              grep "^http"      | #
              sed "s/ /\n/g"    | #
              grep "http.\?://" | #
              sort -u`
   do
      URL=`echo $URL | sed 's/[.!?]*$//'`
      C1=1;C2=6
      URLHASH=`echo $URL | md5sum | #
               cut -d " " -f 1 | sed 's/[^0-9]//g'`
      SHOURL=`echo $URLHASH | cut -c $C1-$C2`
      shourlsGetInfo "$SHOURL"                            >> $LOG
     #echo "$SHOURL $REMOTELONGURL ($STATUS)"

      URL1=`urldecode $URL`
      URL2=`urldecode $REMOTELONGURL`

    while [ "S=$STATUS" != "S=404" ] &&
          [ "U=$URL1" != "U=$URL2" ]; do
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
      MESSAGEPATH=`realpath $MESSAGE | rev | #
                   cut -d "/" -f 2- | rev`
      MEDIA=$MESSAGEPATH/$MEDIA
      if [ -f $MEDIA ]; then
      MEDIAUPLOAD=${TMP}.png
      conformMedia $MEDIA $MEDIAUPLOAD
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
