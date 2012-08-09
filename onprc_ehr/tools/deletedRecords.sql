CREATE TABLE deleted_records (
	id varchar(255) DEFAULT NULL,
	uuid varchar(255) DEFAULT NULL,
	tableName varchar(255) DEFAULT NULL,
	labkeyTable varchar(255) DEFAULT NULL,
	ts datetime,
	created timestamp
)