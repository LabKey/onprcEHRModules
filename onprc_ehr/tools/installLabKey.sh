#!/bin/sh
#
# This script is designed to upgrade LabKey on this server
# usage: ./installLabKey.sh ${distribution}
#

if [ $# -eq 0 ]; then
    echo "Must supply the name of a valid GZ archive"
    exit 2
fi

GZ=$1
echo "Installing LabKey using: $GZ"
cd /usr/local/src
echo "Unzipping $GZ"
gunzip $GZ
TAR=`echo $GZ | sed -e "s/.gz$//"`
echo "TAR: $TAR"
tar -xf $TAR
DIR=`echo $TAR | sed -e "s/.tar$//"`
echo "DIR: $DIR"
cd $DIR
./manual-upgrade.sh -u labkey -n 6.0 -c /usr/local/tomcat -l /usr/local/labkey
cd ../
echo "Removing folder: $DIR"
rm -Rf $DIR
echo "GZipping distribution"
gzip $TAR

