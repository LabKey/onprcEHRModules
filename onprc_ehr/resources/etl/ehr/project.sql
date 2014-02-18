/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
SELECT
	t2.*,
	CASE
		WHEN t2.enddateRaw > CURRENT_TIMESTAMP THEN NULL
		else t2.enddateRaw
	END as enddate

FROM (

select
	--coalesce(i2.eIACUCNum, rtrim(ltrim(lower(i2.IACUCCode)))) as protocol,
	rtrim(ltrim(i2.IACUCCode)) as protocol,
	CASE
		WHEN (t.grantStart IS NOT NULL AND (t.IcacucStartDate IS NULL OR t.IcacucStartDate < t.grantStart)) THEN t.grantStart
		ELSE t.IcacucStartDate
	END as startdate,
    CASE
      WHEN (t.grantEnd IS NOT NULL AND (t.IcacucEndDate IS NULL OR t.IcacucEndDate > t.grantEnd) AND ((coalesce(i2.dateDisabled, i2.EndDate) IS NULL OR coalesce(i2.dateDisabled, i2.EndDate) > t.grantEnd))) THEN t.grantEnd
      WHEN (t.IcacucEndDate IS NULL OR ((coalesce(i2.dateDisabled, i2.EndDate) IS NOT NULL AND coalesce(i2.dateDisabled, i2.EndDate) < t.IcacucEndDate))) THEN coalesce(i2.dateDisabled, i2.EndDate)
      ELSE t.IcacucEndDate
    END as enddateRaw,
	t.*

FROM (

select

    Rpi.ProjectId as project,
    rpi.IACUCCode,
    rtrim(ltrim(Rpi.IACUCCode)) as name,
	coalesce ((select top 1
				ipc.projectparentid
				from Ref_ProjectsIACUC rpi2 join Ref_IACUCParentChildren ipc on (rpi2.ProjectID = ipc.ProjectParentID and ipc.datedisabled is null)
				where ipc.projectchildid = rpi.projectid order by ipc.datecreated desc), rpi.projectid) as protocolId,

	rtrim(ltrim((select top 1 ohsuaccountnumber from Ref_ProjectAccounts rpa where rpi.projectid = rpa.ProjectID order by datecreated desc))) as account,
	Rpi.Title,
	Rpi.StartDate as IcacucStartDate,
	coalesce(rpi.dateDisabled, Rpi.EndDate) as IcacucEndDate,
  (select max(pg.GrantStartDate) as startdate FROM Ref_ProjectGrants pg  WHERE pg.ProjectID = rpi.ProjectID) as grantStart,
	(select max(coalesce(pg.GrantEndDate, pg.datedisabled)) as enddate FROM Ref_ProjectGrants pg  WHERE pg.ProjectID = rpi.ProjectID) as grantEnd,

	CASE
	  WHEN pc2.InvestigatorID IS NULL THEN (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri.firstname and i.lastname = ri.lastname group by i.LastName, i.firstname having count(*) <= 1)
      ELSE (select max(i.rowid) from labkey.onprc_ehr.investigators i where i.firstname = ri2.firstname and i.lastname = ri2.lastname group by i.LastName, i.firstname having count(*) <= 1)
    END as investigatorId,
	rpi.objectid,
	CASE
	  WHEN Rpi.IACUCCode LIKE '%0492%' THEN 0
	  ELSE 1
  END as research,

  CASE
    WHEN Rpi.IACUCCode = '0492' THEN 1  --P51
    ELSE 0
  END as alwaysavailable,

  CASE
    WHEN Rpi.IACUCCode = '0492' THEN 'Base Grant'  --P51
    ELSE null
  END as shortname,

  CASE
    WHEN Rpi.IACUCCode = '0492' THEN 'P51'  --P51
    WHEN Rpi.IACUCCode = '0492-03' THEN 'U24'
    WHEN Rpi.IACUCCode = '0492-02' THEN 'U42'
    WHEN Rpi.IACUCCode = '0300' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0456' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0027' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0833' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0095-50' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0689' THEN 'Center Resource'
    WHEN Rpi.IACUCCode = '0794' THEN 'Center Resource'

    ELSE 'Research'
  END as use_category,
  s2.value as projectType

From Ref_ProjectsIACUC rpi
	left join Ref_ProjInvest pc on (pc.ProjectID = rpi.ProjectID AND pc.DateDisabled is null and pc.PIFlag = 1 and pc.investigatorid != 0)
	left join Ref_Investigator ri on (ri.InvestigatorID = pc.investigatorid)

	left join Ref_ProjInvest pc2 on (pc2.ProjectID = rpi.ProjectID AND pc2.DateDisabled is null and pc2.PIFlag = 2 and pc2.investigatorid != 0)
	left join Ref_Investigator ri2 on (ri2.InvestigatorID = pc2.investigatorid)
  left join Sys_Parameters s2 on (rpi.projecttype = s2.Flag and s2.Field = 'ProjectType')

WHERE (rpi.ts > ? or pc.ts > ? or ri.ts > ?
       OR (select max(ts) as maxts FROM Ref_ProjectGrants g WHERE g.ProjectID = rpi.ProjectID) > ?
       OR (select max(ts) as maxts from Ref_ProjectAccounts rpa where rpi.ProjectID = rpa.ProjectID) > ?
       OR (select max(rpi2.ts) as maxTs from Ref_ProjectsIACUC rpi2 join Ref_IACUCParentChildren ipc on (rpi2.ProjectID = ipc.ProjectParentID and ipc.datedisabled is null) where ipc.projectchildid = rpi.projectid) > ?
)
) t

LEFT JOIN Ref_ProjectsIACUC i2 ON (i2.ProjectID = t.protocolId)
) t2