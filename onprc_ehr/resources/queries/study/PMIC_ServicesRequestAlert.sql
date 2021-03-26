SELECT
       Id,
       date,
       project,
       type,
       procedureid,
       remark,
       QCState,
       requestid,
       taskid,
       created,
       createdby
from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.encounters
Where chargeType like 'PMIC' and date >= now()