#!/bin/sh
#
#
# Copyright (c) 2012 LabKey Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script is designed to upgrade LabKey on this server
# usage: ./installLabKeyPipeline.sh ${distribution}
#

if [ $# -eq 0 ]; then
    echo "Must supply the name of a valid GZ archive"
    exit 2
fi

GZ=$1
echo "Installing LabKey using: $GZ"
service labkeyPipeline stop

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
service labkeyPipeline start
cd ../
echo "Removing folder: $DIR"
rm -Rf $DIR
echo "GZipping distribution"
gzip $TAR

echo "Updating pipeline code"
su labkey -c 'svn update /usr/local/labkey/svn/trunk/pipeline_code/'

echo "cleaning up installers, leaving 5 most recent"
ls -tr | grep '^LabKey.*\.gz$' | head -n -5 | xargs rm