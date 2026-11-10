-- Called daily by the onprc_ehr SLACensusInvestigatorUpdate ETL
CREATE OR REPLACE FUNCTION onprc_ehr.SLACensusInvestigatorUpdate() RETURNS void AS $$
BEGIN
    UPDATE sla.census c
    SET investigatorId = i.objectid
    FROM ehr.project p
        INNER JOIN onprc_ehr.investigators i ON i.rowId = p.investigatorId
    WHERE p.project = c.project
      AND c.date >= '2016-09-01'
      AND c.investigatorId IS NULL
      AND i.objectid IS NOT NULL;
END;
$$ LANGUAGE plpgsql;
