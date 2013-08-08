DELETE FROM hormoneassay.instruments WHERE instrument = 'Roche E411';
INSERT INTO hormoneassay.instruments (instrument) VALUES ('Roche E411');

CREATE TABLE hormoneassay.assay_tests (
  test varchar(100),
  code varchar(100),
  units varchar(100),

  constraint PK_assay_tests PRIMARY KEY (test)
);
GO

INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('ACTH', null, 'pg/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Cortisol', null, 'ug/dl');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('C-Peptide', null, 'ng/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('DHEAS', 'DHEA-S', 'ug/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Estradiol', 'E2', 'pg/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('FSH', 'FSH', 'mIU/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('hCG + B', null, 'mIU/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('hGH', 'hGH', 'ng/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Insulin', null, 'uU/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('LH', 'LH', 'mIU/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Progesterone', 'PROG', 'ng/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Prolactin', null, 'ng/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Total PSA', null, 'ng/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('SHBG', 'SHBG', 'ug/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Free T3', null, 'pg/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Total T3', null, 'ng/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Free T4', null, 'ng/dl');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Total T4', null, 'ug/dl');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Testosterone', 'TESTO', 'ng/ml');
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('TSH', null, 'uIU/ml');


CREATE TABLE hormoneassay.diluents (
  diluent varchar(100),

  constraint PK_diluents PRIMARY KEY (diluent)
);
GO

INSERT INTO hormoneassay.diluents (diluent) VALUES ('DU');
INSERT INTO hormoneassay.diluents (diluent) VALUES ('MA');
INSERT INTO hormoneassay.diluents (diluent) VALUES ('MD1');


