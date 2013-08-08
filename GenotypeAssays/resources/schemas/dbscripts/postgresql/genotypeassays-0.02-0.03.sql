CREATE TABLE genotypeassays.primer_pairs
(
    primerName varchar(255),
    ref_nt_name varchar(255),
    ref_nt_id integer,
    shortName varchar(255),
    forwardPrimer varchar(4000),
    reversePrimer varchar(4000),

    --Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_primers PRIMARY KEY (primerName)
);

DROP TABLE IF EXISTS genotypeassays.ssp_result_types;
CREATE TABLE genotypeassays.ssp_result_types
(
  result varchar(10) NOT NULL,
  meaning varchar(255),
  importAliases varchar(4000),

  CONSTRAINT PK_ssp_result_types PRIMARY KEY (result)
);

INSERT into genotypeassays.ssp_result_types (result, meaning, importAliases) VALUES ('POS', 'Positive', '+,1,Y');
INSERT into genotypeassays.ssp_result_types (result, meaning, importAliases) VALUES ('NEG', 'Negative', '-,0,N');
INSERT into genotypeassays.ssp_result_types (result, meaning, importAliases) VALUES ('IND', 'Indeterminate', null);
INSERT into genotypeassays.ssp_result_types (result, meaning, importAliases) VALUES ('FAIL', 'Fail', 'F');