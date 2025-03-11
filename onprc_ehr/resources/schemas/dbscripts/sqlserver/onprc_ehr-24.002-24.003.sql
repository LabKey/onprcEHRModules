CREATE PROCEDURE onprc_ehr.BaseProtocol
AS
BEGIN
    -- Create a Common Table Expression (CTE) named BaseProtocol
    WITH BaseProtocol AS
             (
                 SELECT
                     RowID,
                     Protocol_id,
                     -- Determine the BaseProtocol based on the length of the Protocol_id
                     CASE
                         WHEN LEN(Protocol_id) > 10 THEN SUBSTRING(Protocol_id, 6, 15)
                         ELSE Protocol_id
                         END AS BaseProtocol,
                     -- Determine the RevisionNumber based on the length of the Protocol_id
                     CASE
                         WHEN LEN(Protocol_id) > 10 THEN SUBSTRING(Protocol_id,1, 5)
                         ELSE 'Original'
                         END AS RevisionNumber,
                     approval_date,
                     Three_Year_Expiration,
                     last_modified,
                     Protocol_State
                 FROM onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
             )

    -- Update the onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS table with BaseProtocol and RevisionNumber from the CTE
    UPDATE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    SET BaseProtocol = BaseProtocol.BaseProtocol,
        RevisionNumber = BaseProtocol.RevisionNumber
    FROM BaseProtocol
    WHERE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS.RowID = BaseProtocol.RowID;
END
GO