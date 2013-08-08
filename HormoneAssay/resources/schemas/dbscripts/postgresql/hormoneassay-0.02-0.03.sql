DELETE FROM hormoneassay.assay_tests WHERE test = 'Progesterone';
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Progesterone', 'P4', 'ng/ml');