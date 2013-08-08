/*
 * Copyright (c) 2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- Create schema, tables, indexes, and constraints used for hormoneassay module here
-- All SQL VIEW definitions should be created in hormoneassay-create.sql and dropped in hormoneassay-drop.sql
CREATE SCHEMA hormoneassay;
GO

CREATE TABLE hormoneassay.RocheE411_Tests (
  test varchar(100),
  code varchar(100),
  sampletype varchar(100),
  samplevolume double precision,
  rangemin double precision,
  rangemax double precision,
  units varchar(100),
  assaytype varchar(100),
  controlmodule varchar(100),
  samplediluent varchar(100),
  testkey int,

  CreatedBy USERID,
  Created DATETIME,
  ModifiedBy USERID,
  Modified DATETIME,

  constraint PK_rochee411_tests PRIMARY KEY (test)
);

CREATE TABLE hormoneassay.instruments (
    instrument VARCHAR(200) NOT NULL,

    CONSTRAINT PK_instruments PRIMARY KEY (instrument)
);

INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('ACTH', null, 'P(EDTA)', 50, 1, 2000, 'pg/ml', 'sand', 'PCMM', 'MD1', '80');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Cortisol', null, 'S,P,Sal,U', 20, 0.036, 63.4, 'ug/dl', 'comp', 'PCU', 'DU', '160');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('C-Peptide', null, 'S,P,U', 20, 0.01, 40, 'ng/ml', 'sand', 'MA/MM?', 'MA', '70');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('DHEAS', 'DHEA-S', 'S,P', 15, 0.001, 10, 'ug/ml', 'comp', 'PCU', 'none', '740');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Estradiol', 'E2', 'S,P', 35, 5, 4300, 'pg/ml', 'comp', 'PCU', 'MA', '101');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('FSH', 'FSH', 'S,P', 40, 0.1, 200, 'mIU/ml', 'sand', 'PCU', 'none', '150');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('hCG + B', null, 'S,P', 10, 0.1, 10000, 'mIU/ml', 'sand', 'PCU', 'DU', '761');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('hGH', 'hGH', 'S,P', 40, 0.03, 50, 'ng/ml', 'sand', 'PCMM', 'DU', '890');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Insulin', null, 'S,P', 20, 0.2, 1000, 'uU/ml', 'sand', 'PCU/MM', 'none', '650');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('LH', 'LH', 'S,P', 20, 0.1, 200, 'mIU/ml', 'sand', 'PCU', 'none', '140');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Progesterone', 'PROG', 'S,P', 30, 0.03, 60, 'ng/ml', 'comp', 'PCU', 'MD1', '121');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Prolactin', null, 'S,P', 10, 0.047, 470, 'ng/ml', 'sand', 'PCU', 'DU', '131');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Total PSA', null, 'S,P', 0, 0.006, 100, 'ng/ml', 'sand', 'PCU/TM', 'DU', '321');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('SHBG', 'SHBG', 'S,P(h,c)', 10, 0.033, 19, 'ug/ml', 'sand', 'PCU', 'MA', '750');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Free T3', null, 'S,P', 15, 0.26, 32.55, 'pg/ml', 'comp', 'PCU', 'N/A', '61');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Total T3', null, 'S,P', 30, 0.195, 6.51, 'ng/ml', 'comp', 'PCU', 'none', '50');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Free T4', null, 'S,P', 15, 0.023, 7.77, 'ng/dl', 'comp', 'PCU', 'N/A', '30');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Total T4', null, 'S,P', 15, 0.42, 24.9, 'ug/dl', 'comp', 'PCU', 'none', '21');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('Testosterone', 'TESTO', 'S,P', 20, 0.025, 15, 'ng/ml', 'comp', 'PCU', 'MD1', '111');
INSERT INTO hormoneassay.rochee411_tests (test,code,sampletype,samplevolume,rangemin,rangemax,units,assaytype,controlmodule,samplediluent,testkey) VALUES ('TSH', null, 'S,P', 50, 0.005, 100, 'uIU/ml', 'sand', 'PCU', 'MA', '10');
