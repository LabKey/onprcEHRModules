#!/bin/bash

#this script can be ignored initially.  

SQLDB=colony
SQLUSER=root
SQLHOST=xxxxxxxx


DATE_CUTOFF_FILE=./date-cutoff.txt
DATE_CUTOFF_INTERVAL="-6 MONTH"

if [ -z "${MYSQLPWD}" ]; then
    echo "Set MYSQLPWD env variable before calling this script"
    exit 1
fi

if [ -z "${SQLDB}" ]; then
    echo "Set SQLDB env variable before calling this script"
    exit 1
fi

if [ -z "${SETUP}" ]; then

    echo "Running setup.sql"
#TODO: needs to be adjusted for SQLServer
    mysql -u${SQLUSER} -p${MYSQLPWD} -D ${SQLDB} -B -h $SQLHOST < scripts/setup/setup.sql
    if [ $? -ne 0 ]; then
        echo "ERROR trying to setup mysql functions"
        exit 1
    fi

    if [ -z "${DATE_CUTOFF}" ]; then
        echo "Selecting cutoff date from mysql"
        mysql -u${SQLUSER} -p${MYSQLPWD} -B -h $SQLHOST -D${SQLDB} --skip-column-names \
            -e "select DATE_ADD(DATE(NOW()), INTERVAL ${DATE_CUTOFF_INTERVAL})" > ${DATE_CUTOFF_FILE}
        if [ $? -ne 0 ]; then
            echo "ERROR trying to get date cutoff from mysql"
            exit 1
        fi
        if [ ! -f "${DATE_CUTOFF_FILE}" ]; then
            echo "ERROR failed to create date cutoff file"
            exit 1
        fi
        export DATE_CUTOFF=`cat ${DATE_CUTOFF_FILE}`
    fi
    echo "Using date cutoff: ${DATE_CUTOFF}"

    export SETUP=true
fi
