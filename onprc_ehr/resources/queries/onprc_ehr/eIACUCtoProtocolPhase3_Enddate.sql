--Truncate Table onprc_ehr.protocolUpdate

Select
--"Expired Protocol" as Result,
    p.protocol,
    p.title,
    p.investigatorId,
    e.approval_Date as approve,
    p.lastAnnualReview,
    e.Last_Modified as enddate,
    p.external_id,
    p.ibc_approval_num,
    p.usda_level,
    p.last_modification,
    'Protocol Expired in eiACUC ' as description,
    p.container,
    p.contacts,
    e.PPQ_Numbers,
    e.PROTOCOL_State,
    e.RenewalNumber,
    e.Template_OID,
    e.Approval_Date,
    e.Annual_Update_Due as Annual_Update_Due,
    e.THree_Year_Expiration as Three_year_Expiration,
    e.last_modified,
    p.displayName,
    p.annualReviewDate,
    p.daysUntilAnnualReview,
    p.renewalDate,
    p.daysUntilRenewal,
    e.LatestRenewal


from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e  join onprc_ehr.ehr.protocolUpdate p on e.baseProtocol = p.external_Id
where (e.latestRenewal = 1  and e.Protocol_state = 'Expired')

