--I want to expand this to show dall dates in ehr.protocol
SELECT
    e.Protocol_State,
    e.PPQ_Numbers,
    p.Title,
    p.InvestigatorID,
    e.Last_Modified,
    e.Approval_Date as approve,
    e.Annual_Update_Due as AnnualReviewDate,
    e.Three_year_Expiration as renewalDate,
    e.usda_Level,
    e.template_OID,
    e.renewalNumber as RenewalNumber,
    p.external_id

from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e join  ehr.protocol p on e.BaseProtocol = p.external_id
where e.LatestRenewal = 1