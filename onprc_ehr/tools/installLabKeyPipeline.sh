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
# usage: ./installLabKeyPipeline.sh ${distribution}
#

GZ=$1
if [ $# -eq 0 ]; then
    wget -r --trust-server-names --no-check-certificate http://teamcity.labkey.org/guestAuth/repository/download/LabkeyONPRC151_Installers/.lastSuccessful/onprc/LabKey15.1ONPRC-{build.number}-onprc-bin.tar.gz
    mv ./teamcity.labkey.org/guestAuth/repository/download/LabkeyONPRC151_Installers/.lastSuccessful/onprc/*.gz ./
    rm -Rf ./teamcity.labkey.org
    GZ=$(ls -tr | grep '^LabKey.*\.gz$' | tail -n -1)
fi

LABKEY_DIR=/usr/local/labkey
echo "Installing LabKey using: $GZ"
service labkeyRemotePipeline stop

echo "Unzipping $GZ"
gunzip $GZ
TAR=`echo $GZ | sed -e "s/.gz$//"`
echo "TAR: $TAR"
tar -xf $TAR
DIR=`echo $TAR | sed -e "s/.tar$//"`
echo "DIR: $DIR"
cd $DIR
./manual-upgrade.sh -u labkey -c /usr/local/tomcat -l ${LABKEY_DIR}
service labkeyRemotePipeline start
cd ../
echo "Removing folder: $DIR"
rm -Rf $DIR
echo "GZipping distribution"
gzip $TAR

#checkout pipeline code from svn
if [ ! -e ${LABKEY_DIR}/svn ];
then
    echo "Checking out pipeline code"
    su labkey -c "svn co --username cpas --password cpas --no-auth-cache https://hedgehog.fhcrc.org/tor/stedi/trunk/externalModules/labModules/SequenceAnalysis/pipeline_code ${LABKEY_DIR}/svn/trunk/pipeline_code/"
else
    echo "Updating pipeline code"
    su labkey -c "svn update --username cpas --password cpas --no-auth-cache ${LABKEY_DIR}/svn/trunk/pipeline_code/"
fi

echo "cleaning up installers, leaving 3 most recent"
ls -tr | grep '^LabKey.*\.gz$' | head -n -3 | xargs rm

${LABKEY_DIR}/svn/trunk/pipeline_code/sequence_tools_install.sh -d ${LABKEY_DIR} -u labkey