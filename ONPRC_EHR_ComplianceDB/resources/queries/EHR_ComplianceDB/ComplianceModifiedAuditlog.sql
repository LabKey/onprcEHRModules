-- Created 1-3-2023  R. Blasa


select  distinct a.comment,
                 (select b.Lastname + ', ' + b.firstname from onprc_ehr.usersactivenames b where a.createdby = b.userid) as createdby,
                 a.created,
                 a.queryname,
                 a.oldrecordmap,
                 a.newrecordmap
from auditlog.QueryUpdateAuditEvent a
    Where (a.comment like '%updated%' or a.comment like '%deleted%')
  And a.queryname in ('completiondates')

order by a.created desc
