IF EXISTS (SELECT 1 from INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'observation_types' AND TABLE_SCHEMA = 'onprc_ehr')
  DROP TABLE onprc_ehr.observation_types
GO