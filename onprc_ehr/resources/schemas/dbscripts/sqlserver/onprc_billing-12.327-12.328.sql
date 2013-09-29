ALTER TABLE onprc_billing.miscCharges ADD objectid entityid NOT NULL;

GO
EXEC core.fn_dropifexists 'miscCharges', 'onprc_billing', 'CONSTRAINT', 'pk_miscCharges';

ALTER TABLE onprc_billing.miscCharges ADD CONSTRAINT pk_miscCharges PRIMARY KEY (objectid);