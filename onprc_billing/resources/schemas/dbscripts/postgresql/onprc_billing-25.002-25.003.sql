SELECT core.fn_dropifexists('ogaSynch', 'onprc_billing', 'COLUMN', 'OGA_AWARD_START_DATE');
SELECT core.fn_dropifexists('ogaSynch', 'onprc_billing', 'COLUMN', 'OGA_AWARD_END_DATE');
SELECT core.fn_dropifexists('ogaSynch', 'onprc_billing', 'COLUMN', 'IndirectRate');

ALTER TABLE onprc_billing.ogaSynch ADD OGA_AWARD_START_DATE DATE NULL;
ALTER TABLE onprc_billing.ogaSynch ADD OGA_AWARD_END_DATE DATE NULL;
ALTER TABLE onprc_billing.ogaSynch ADD IndirectRate DOUBLE PRECISION NULL;
