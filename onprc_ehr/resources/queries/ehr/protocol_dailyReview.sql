/*' updated 2022-07-28 2nd tgry*/
SELECT l.protocol,
l.inves,
l.approve,
l.description,
l.createdby,
l.created,
l.modifiedby,
l.modified,
l.maxanimals,
l.enddate,
l.title,
l.usda_level,
l.external_id,
l.project_type,
l.ibc_approval_required,
l.ibc_approval_num,
l.investigatorId,
l.last_modification,
l.first_approval,
l.container,
l.objectid,
l.lastAnnualReview


FROM protocol l, onprc_ehr.protocol_logs lg
where l.protocol =  lg.protocol