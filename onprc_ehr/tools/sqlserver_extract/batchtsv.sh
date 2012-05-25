#!/bin/bash
#generate tsv files
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


#this is where the TSV files are created
PIPELINE_ROOT=/Users/bimber/mysql-dump
STUDY_DIR=${PIPELINE_ROOT}

#can ingore this..
STUDY_LOAD_FILE=${PIPELINE_ROOT}/studyload.txt

#TODO: consider enabling this to test date cutoff
#. setup.sh

for script in scripts/dataset/*.sql
do
    fname=${script##*/}
    basename=${fname%%.*}
    echo
    echo "** dataset $basename"
    time ./generatetsv.sh $script ${STUDY_DIR}/datasets/${basename}.tsv
    if [ $? -ne 0 ]; then
        echo "Failed running '$script', exiting early"
        exit 1
    fi
done

#we will address this once datasets are done
#for script in scripts/lists/*.sql
#do
#    fname=${script##*/}
#    basename=${fname%%.*}
#    echo
#    echo "** list $basename"
#    time ./generatetsv.sh $script ${STUDY_DIR}/lists/${basename}.tsv
#    if [ $? -ne 0 ]; then
#        echo "Failed running '$script', exiting early"
#        exit 1
#    fi
#done

touch ${STUDY_LOAD_FILE}
echo "Finished dumping all tsv files."
