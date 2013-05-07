--implemented based on SQLServer database engine tuning monitor
CREATE INDEX investigators_rowid_lastname ON onprc_ehr.investigators (rowid, lastname);