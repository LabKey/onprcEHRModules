
-- Created: 10-10-2022  R. Blasa to correct type definitionss


ALTER TABLE onprc_ehr.encounter_summaries_remarks ALTER COLUMN createdby userid;
GO


ALTER TABLE onprc_ehr.encounter_summaries_remarks ALTER COLUMN modifiedby userid;
GO