SELECT p.protocol,
Case
	When p.displayName = l.protocol then 'No Action'
	Else 'Needs Review'
	End as ProtocolChange,
l.protocol as LogLink,
p.title,
Case
	When p.title = (Select l.title from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as TitleChange,
--(Select l.title from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as titleCheck,
p.investigatorId,
Case
	When p.InvestigatorID is Null then 'None Listed'
	When p.InvestigatorID = (Select l.investigatorID from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as InvestChange,
--(Select l.investigatorID from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as InvestCheck,
p.approve,
Case
	When p.approve is Null then 'None Listed'
	When p.approve = (Select l.approve from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as lastAnnualReview_Change,
--(Select l.approve from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as lastAnnualReview_Check,

p.lastAnnualReview,
Case
	When p.lastAnnualReview is Null then 'None Listed'
	When p.lastAnnualReview = (Select l.lastAnnualReview from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as ApprovChange,
--(Select l.approve from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as lastAnnualReview_Check,
p.enddate,
Case
	When p.enddate is Null then 'None Listed'
	When p.enddate = (Select l.enddate from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as enddate_Change,
--(Select l.enddate from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as enddate_Check,
p.external_id,
Case
	When p.external_id is Null then 'None Listed'
	When p.external_id = (Select l.external_id from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as external_id_Change,
--(Select l.external_id from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as external_id_Check,
p.ibc_approval_num,
Case
	When p.ibc_approval_num is Null then 'None Listed'
	When p.ibc_approval_num = (Select l.ibc_approval_num from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as ibc_approval_num_Change,
(Select l.ibc_approval_num from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as ibc_approval_num_Check,
p.usda_level,
Case
	When p.usda_level is Null then 'None Listed'
	When p.usda_level = (Select l.usda_level from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as usda_level_Change,
(Select l.usda_level from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as usda_level_Check,

p.last_modification,
Case
	When p.last_modification is Null then 'None Listed'
	When p.last_modification = (Select l.last_modification from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as last_modification_Change,
(Select l.last_modification from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as last_modification_Check,
p.description,
Case
	When p.description is Null then 'None Listed'
	When p.description = (Select l.description from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as description_Change,
(Select l.description from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as description_Check,

p.contacts,
Case
	When p.contacts is Null then 'None Listed'
	When p.contacts = (Select l.contacts from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as contacts_Change,
(Select l.contacts from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as contacts_Check,
p.PPQ_Numbers,
Case
	When p.PPQ_Numbers is Null then 'None Listed'
	When p.PPQ_Numbers = (Select l.PPQ_Numbers from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as PPQ_Numbers_Change,
(Select l.PPQ_Numbers from onprc_ehr.protocol_logs l where p.displayName = l.protocol) as PPQ_Numbers_Check,
p.PROTOCOL_State,
Case
	When p.PROTOCOL_State is Null then 'None Listed'
	When p.PROTOCOL_State = (Select l.PROTOCOL_State from onprc_ehr.protocol_logs l where p.displayName = l.protocol) then 'No Action'
	Else 'Needs Review'
	End as PROTOCOL_State_Change,
(Select l.PROTOCOL_State from onprc_ehr.protocol_logs l where p.displayName = l.protocol) asPROTOCOL_State_Check,

p.Template_OID,
p.Approval_Date,
p.Annual_Update_Due,
p.Three_year_Expiration,
p.last_modified,
p.displayName,
p.annualReviewDate,
p.daysUntilAnnualReview,
p.renewalDate,
p.daysUntilRenewal
FROM protocol p left outer join onprc_ehr.protocol_logs l on p.displayname = l.protocol
where (l.enddate > '8/1/2022' or l.enddate is null)