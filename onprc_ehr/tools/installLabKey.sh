#!/bin/sh
#
#
# Copyright (c) 2012-2015 LabKey Corporation
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
# usage: ./installLabKey.sh ${distribution}
#

GZ=$1
if [ $# -eq 0 ]; then
    wget -r --trust-server-names --no-check-certificate http://teamcity.labkey.org/guestAuth/repository/download/LabkeyONPRC151_Installers/.lastSuccessful/onprc/LabKey15.1ONPRC-{build.number}-onprc-bin.tar.gz
    GZ=$(ls -tr | grep '^LabKey.*\.gz$' | tail -n -1)
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
./manual-upgrade.sh -u labkey -c /usr/local/tomcat -l /usr/local/labkey
cd ../
echo "Removing folder: $DIR"
rm -Rf $DIR
echo "GZipping distribution"
gzip $TAR

echo "Updating reference study"
su labkey -c 'svn --no-auth-cache --username cpas --password cpas update /lkfiles/studyDefinition/Study'

echo "cleaning up installers, leaving 5 most recent"
ls -tr | grep '^LabKey.*\.gz$' | head -n -5 | xargs rm