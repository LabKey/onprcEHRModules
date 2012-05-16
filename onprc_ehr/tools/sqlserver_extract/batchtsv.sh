#!/bin/bash
#generate tsv files

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
