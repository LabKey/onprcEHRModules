this folder contains scripts designed to dump all ONPRC IRIS tables to TSV files,
then import them into a separate schema called col_dump.  it does not create this schema.
there is a separate SQL script called col_dump.sql which has the create statements, written for postgres.

batchtsv.sh will dump all mySQL tables to TSV files
generatetsv.sh is called by batchtsv.sh

importdata.sh should be run second.  it will import all of the TSV files created above and import into postgres

