#!/bin/bash
set -e

export ZKTX=$1
export ZKSNAP=$2
export KEEP=$3

#echo "Zookeeper Cleanup"
#echo "================="
#echo ""
#echo "ZK TXLOG path $ZKTX"
#echo "ZK SNAPSHOT path $ZKSNAP"
#echo "Throw away all but the latest $KEEP snapshots and their incrementing tx-logs..."
#echo ""

reffile=`find $ZKSNAP -name "snapshot*" -type f -printf '%T@ %p\n' | sort -k 1nr | sed 's/^[^ ]* //' | sed "$KEEP!d"`
if [ ! -z $reffile ]; then 
  find $ZKTX -name "log*" -type f ! -newer $reffile -exec ls -l {} \; -exec rm {} \;
fi

export DEL=$(($KEEP+1))
delfile=`find $ZKSNAP -name "snapshot*" -type f -printf '%T@ %p\n' | sort -k 1nr | sed 's/^[^ ]* //' | sed "$DEL!d"`
if [ ! -z $delfile ]; then 
  find $ZKSNAP -name "snapshot*" -type f ! -newer $delfile -exec ls -l {} \; -exec rm {} \;
fi