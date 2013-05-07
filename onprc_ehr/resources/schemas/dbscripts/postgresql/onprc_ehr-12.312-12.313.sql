create table onprc_ehr.serology_test_schedule (
  rowid serial,
  code varchar(100),
  flag varchar(100),
  interval int,

  CONSTRAINT PK_serology_test_schedule PRIMARY KEY (rowid)
);

INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32140','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY351','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3284','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY331','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32221','SPF 9', 1);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32140','SPF 9', 3);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32218','SPF 9', 1);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY351','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY370','SPF 9', 1);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3283','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3284','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3287','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY331','SPF 9', 12);
