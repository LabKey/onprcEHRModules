/*This one is going tio take some thought to determine how to do the insert as the protocol will be an incremental Number*/

Select
    'New Protocol' as Result,
    e.Protocol_ID,
    e.Protocol_Title,
   /* p.investigatorId,
    e.approval_Date as approve,
    p.lastAnnualReview,
    p.enddate,
    p.external_id,
    p.ibc_approval_num,
    p.usda_level,
    p.last_modification,
    p.description,
    p.container,
    p.contacts,
    e.PPQ_Numbers,
    e.PROTOCOL_State,
    e.RenewalNumber,
    e.Template_OID,*/
    e.Approval_Date,
    e.Annual_Update_Due as Annual_Update_Due,
    e.THree_Year_Expiration as Three_year_Expiration,
    e.last_modified,
    p.displayName,
    p.annualReviewDate,
    p.daysUntilAnnualReview,
    p.renewalDate,
    p.daysUntilRenewal


from  onprc_ehr.ehr.protocol p join onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS e on e.baseProtocol != p.external_Id
