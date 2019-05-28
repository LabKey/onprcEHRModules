#!/bin/sh
#
# This script is designed to remove any files from the munin library with old timestamps
# These are typically diskstats or other files from previously removed devices
# Removing files we do not care about allows munin-monitor.pl to more accurately determine if we are collecting data for the other metrics

echo "Removing the following files:"
cat /var/log/munin-error

FILENAME=/var/log/munin-error
WORDCOUNT=`wc -w $FILENAME | cut -f1 -d' '`

if [[ $WORDCOUNT > 0 ]]; then
   cat $FILENAME | xargs echo rm | sh
fi
