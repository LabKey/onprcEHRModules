--This build is a stored preoccured that uses a temp table and then updates onprc_ehronprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
ALTER Procedure onprc_ehr.BaseProtocol

    AS
--Create a Temp Table that creates Base Protocol and Revision Number
    WITH BaseProtocol AS (
    SELECT
    RowID,
    Protocol_id,
    CASE
    WHEN LEN(protocol_id) > 10 THEN SUBSTRING(protocol_id, 6, 15)
    ELSE protocol_id
    END AS BaseProtocol,
    CASE
    WHEN LEN(protocol_id) > 10 THEN SUBSTRING(protocol_ID,1, 5)
    ELSE 'Original'
    END AS RevisionNumber,
    approval_date,
    Three_Year_Expiration,
    last_modified,
    Protocol_State
    FROM
    onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    )
--This will update the onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS inserting the BaseProtocol and RevisionNumber
Update e
Set e.BaseProtocol = p.BaseProtocol, e.RevisionNumber = p.revisionNumber
--
    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e, BaseProtocol p
where e.rowID = p.rowID

