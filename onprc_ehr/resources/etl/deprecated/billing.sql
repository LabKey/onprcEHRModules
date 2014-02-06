/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
--chargableItems, only importing new items
INSERT INTO labkey.onprc_billing.chargeableItems
(name, shortName, category, itemCode, departmentCode, active, container)

SELECT t.name, t.shortName, t.category, t.itemCode, t.departmentCode, t.active, t.container FROM (

SELECT
  t.name,
  max(t.shortname) as shortname,
  max(t.category) as category,
  max(t.itemcode) as itemcode,
  max(t.departmentcode) as departmentcode,
  min(active) as active,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM (
Select
  'Small Animal Fees - ' + s2.Value + ': ' + s3.Value + ', ' + s4.value as name,
  'Small Animal Fees' as shortname,
  'Small Animal Per Diem' as category,
  '7' as itemcode,
  'SLAU' as departmentcode,
  CASE WHEN rf.DateDisabled IS NULL THEN 1 ELSE 0 END as active
From IRIS_Production.dbo.Ref_FeesRodents rf
--LEFT JOIN IRIS_Production.dbo.Sys_Parameters s1 on (rf.Species = s1.Flag And s1.Field = 'SmallAnimals')
  LEFT JOIN IRIS_Production.dbo.Sys_Parameters s2 on (rf.CageType  = s2.Flag And s2.Field = 'SmallCageType')
  LEFT JOIN IRIS_Production.dbo.Sys_Parameters s3 on (rf.CageSize  = s3.Flag And s3.Field = 'SmallCageSize')
  LEFT JOIN IRIS_Production.dbo.Sys_Parameters s4 on (rf.Species  = s4.Flag And s4.Field = 'SmallAnimals')
  where rf.DateDisabled is null
) t where name is not null GROUP BY t.name
-- EO Rodent definitions

UNION ALL

SELECT
  rfp.ProcedureName as name,
  null as shortName,
  s3.value as category,
  rfp.ProcedureID as itemCode,
  'PDAR' as departmentCode,
  CASE WHEN rfp.DateDisabled IS NULL THEN 1 ELSE 0 END as active,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM IRIS_Production.dbo.Ref_FeesProcedures rfp
left join IRIS_Production.dbo.Sys_Parameters s3 on (s3.Field = 'ChargeType'and s3.Flag = rfp.ChargeType)

UNION ALL

--add ref_feesSurgical to chargeableItems
select
	t.name,
  max(t.shortName) as shortName,
	'Surgery' as category,
  max(t.itemCode) as itemCode,
  'PSURG' as departmentCode,
	MAX(t.active) as active,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM (

Select
	s.ProcedureName + ' - No Staff' as name,
  s.ProcedureName as shortName,
  fs.ProcedureID as itemCode,
	CASE WHEN fs.DateDisabled is null THEN 1 else 0 END as active

From IRIS_Production.dbo.Ref_FeesSurgical fs
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
WHERE s.procedureName IS NOT NULL
UNION ALL

Select
	s.ProcedureName + ' - Staff' as name,
  s.ProcedureName as shortName,
  fs.ProcedureID as itemCode,
	CASE WHEN fs.DateDisabled is null THEN 1 else 0 END as active

From IRIS_Production.dbo.Ref_FeesSurgical fs
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
WHERE s.procedureName IS NOT NULL
) t

GROUP BY name

UNION ALL
--add lease fees to chargeableItems
SELECT
	name,
  max(shortName) as shortName,
	'Lease Fees' as category,
  max(t.itemCode) as itemCode,
  'PDAR' as departmentCode,
	1 as active,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

FROM (
Select
	CASE
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Lease Setup Fees' THEN rf.ProcedureName
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Animal Lease Fee' THEN rf.ProcedureName + ' - TMB'
		WHEN s1.Value IS null THEN rf.ProcedureName + ' - General: ' + cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
		ELSE rf.ProcedureName + ' - ' + s1.Value + ': ' +  cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
	END as name,
  rf.ProcedureName as shortName,
  rfl.ProcedureID as itemCode

From IRIS_Production.dbo.Ref_FeesLease rfl
      left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Flag = rfl.AgeCategory and s1.Field = 'AgeCategory')
      left join IRIS_Production.dbo.Ref_FeesProcedures rf ON (rf.ProcedureID = rfl.procedureId)
      left join labkey.onprc_billing.chargeableItems lk ON (lk.name = rf.procedureName)
where rfl.DateDisabled is null
) t
GROUP BY name

--TODO: procedure fee definition

) t
LEFT JOIN labkey.onprc_billing.chargeableItems ci ON (ci.name = t.name)
WHERE ci.name IS NULL;




--chargeableExemptions
TRUNCATE TABLE labkey.onprc_billing.chargeRateExemptions;
INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitCost, startDate, enddate, container)
SELECT
  projectId,
  (SELECT max(rowid) FROM labkey.onprc_billing.chargeableItems ci WHERE ci.name = r.ProcedureName) as chargeId,
  ChargeAmount as unitCost,
  rf.DateCreated as startDate,
  rf.DateDisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM IRIS_Production.dbo.Ref_FeesSpecial rf
left join IRIS_Production.dbo.Ref_FeesProcedures r ON (rf.ProcedureID = r.ProcedureID)
WHERE coalesce(rf.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02';

-- NOTE: the way PRIMe and IRIS handle lease fees is different.  PRIMe has more categories
-- for these charges, so expand out that list on exemptions
INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitCost, startDate, enddate, container)
SELECT
  projectId,
  lfd.chargeId,
  ChargeAmount as unitCost,
  rf.DateCreated as startDate,
  rf.DateDisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM IRIS_Production.dbo.Ref_FeesSpecial rf
  left join IRIS_Production.dbo.Ref_FeesProcedures r ON (rf.ProcedureID = r.ProcedureID)
  left join labkey.onprc_billing.leaseFeeDefinition lfd on (lfd.chargeId != (select rowId from labkey.onprc_billing.chargeableItems where name = 'Lease Setup Fees'))
WHERE (r.procedureName = 'Animal Lease Fee' and rf.DateDisabled is null)
AND coalesce(rf.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02';
--EO: lease fee exemptions

--we also need special handling of per diems / tiers
INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitCost, startDate, enddate, container)
SELECT * FROM (
SELECT
  t.projectId,
  (SELECT max(rowid) FROM labkey.onprc_billing.chargeableItems ci WHERE ci.name = (t.ProcedureName + t2.col)) as chargeId,
  t.unitCost,
  t.startDate,
  t.enddate,
  t.container
FROM (
SELECT
  projectId,
  procedureName,
  ChargeAmount as unitCost,
  rf.DateCreated as startDate,
  rf.DateDisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM IRIS_Production.dbo.Ref_FeesSpecial rf
left join IRIS_Production.dbo.Ref_FeesProcedures r ON (rf.ProcedureID = r.ProcedureID)
WHERE coalesce(rf.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02'
and r.ProcedureName like 'Per Diem%'
) t
LEFT JOIN (SELECT * FROM (select ' Tier 1' as col UNION ALL SELECT ' Tier 2' UNION ALL SELECT ' Tier 3') t4) t2 on (1=1)
) t2 WHERE t2.chargeId IS NOT NULL AND t2.enddate IS NULL


INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitCost, startDate, enddate, container)
Select
	fs.ProjectID,					--Ref_ProjectsIacuc
	lk.rowid as chargeid,
	--lk.name,
	--fs.ChargeAmountStaff,
	fs.ChargeAmountNoStaff as unitCost,
	--fs.ChargeDate,
	fs.DateCreated as startdate,
	fs.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSpecialSurg fs
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = s.procedureName + ' - No Staff' AND lk.category = 'Surgery')
WHERE coalesce(fs.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02';

INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitCost, startDate, enddate, container)
Select
	fs.ProjectID,					--Ref_ProjectsIacuc
	lk.rowid as chargeid,
	--lk.name,
	fs.ChargeAmountStaff as unitCost,
	--fs.ChargeAmountNoStaff as unitCost,
	--fs.ChargeDate,
	fs.DateCreated as startdate,
	fs.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSpecialSurg fs
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = s.procedureName + ' - Staff' AND lk.category = 'Surgery')
WHERE coalesce(fs.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02';

--creditAccount
TRUNCATE TABLE labkey.onprc_billing.creditAccount;
INSERT INTO labkey.onprc_billing.creditAccount
(chargeId, account, startDate, enddate, container)
Select
	lk.rowid as chargeId,
	--f.ItemCode,				--Ref_FeesProcedures, Ref_SurgProcedure
	f.CreditAlias as account,
	f.DateCreated as startdate,
	f.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesCreditAlias f
left join IRIS_Production.dbo.Ref_FeesProcedures fp ON (f.ItemCode = cast(fp.ProcedureID as nvarchar) + 'C')
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = fp.procedureName)
WHERE lk.rowid is not null;

--lease fees
INSERT INTO labkey.onprc_billing.creditAccount
(chargeId, account, startDate, enddate, container)
select
  lfd.chargeId,
--f.ItemCode,				--Ref_FeesProcedures, Ref_SurgProcedure
  f.CreditAlias as account,
  f.DateCreated as startdate,
  f.DateDisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesCreditAlias f
  left join IRIS_Production.dbo.Ref_FeesProcedures fp ON (f.ItemCode = cast(fp.ProcedureID as nvarchar) + 'C')
  left join labkey.onprc_billing.chargeableItems lk ON (lk.name = fp.procedureName)
  left join labkey.onprc_billing.leaseFeeDefinition lfd on (lfd.chargeId != (select rowId from labkey.onprc_billing.chargeableItems where name = 'Lease Setup Fees'))
WHERE fp.ProcedureName = 'Animal Lease Fee' and lfd.chargeId is not null;

--surgery
INSERT INTO labkey.onprc_billing.creditAccount
(chargeId, account, startDate, enddate, container)
select
  lk.rowId AS chargeId,
  --lk.name,
  --fs.ChargeCode,
  --f.ItemCode,				--Ref_FeesProcedures, Ref_SurgProcedure
  --s.ProcedureID,
  coalesce(f.CreditAlias, '90184863') as account,
  COALESCE(f.DateCreated, '') as startdate,
  f.DateDisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_SurgProcedure s
  JOIN IRIS_Production.dbo.Ref_FeesSurgical fs ON (fs.ProcedureID = s.ProcedureID and fs.DateDisabled is null)
  left JOIN IRIS_Production.dbo.Ref_FeesCreditAlias f ON (f.ItemCode = cast(fs.ProcedureID as nvarchar(10)) + 'C' and f.DateDisabled is null)
  left join labkey.onprc_billing.chargeableItems lk ON (lk.category = 'Surgery' AND (lk.name LIKE s.ProcedureName + ' - Staff' OR lk.name LIKE s.ProcedureName + ' - No Staff'))
  WHERE lk.rowId is not null

--SLA
INSERT INTO labkey.onprc_billing.creditAccount
(chargeId, account, startDate, enddate, container)
Select
  (select max(rowid) from labkey.onprc_billing.chargeableItems ci WHERE ci.active = 1 AND ci.name = 'Small Animal Fees - ' + s2.Value + ': ' + s3.Value + ', ' + s4.value) as chargeId,
  -1 as account,
  rf.dateCreated as startdate,
  rf.datedisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
  From IRIS_Production.dbo.Ref_FeesRodents rf
    LEFT JOIN IRIS_Production.dbo.Sys_Parameters s2 on (rf.CageType  = s2.Flag And s2.Field = 'SmallCageType')
    LEFT JOIN IRIS_Production.dbo.Sys_Parameters s3 on (rf.CageSize  = s3.Flag And s3.Field = 'SmallCageSize')
    LEFT JOIN IRIS_Production.dbo.Sys_Parameters s4 on (rf.Species  = s4.Flag And s4.Field = 'SmallAnimals')

--EO credit account

--charge rates
TRUNCATE TABLE labkey.onprc_billing.chargeRates;
INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitCost, startDate, enddate, container)
  select * from (
  Select
    (select max(rowid) from labkey.onprc_billing.chargeableItems ci WHERE ci.active = 1 AND ci.name = 'Small Animal Fees - ' + s2.Value + ': ' + s3.Value + ', ' + s4.value) as chargeId,
    rf.BaseCharge as unitCost,
    rf.DateCreated as startdate,
    rf.DateDisabled as enddate,
    (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

  From IRIS_Production.dbo.Ref_FeesRodents rf
    LEFT JOIN IRIS_Production.dbo.Sys_Parameters s2 on (rf.CageType  = s2.Flag And s2.Field = 'SmallCageType')
    LEFT JOIN IRIS_Production.dbo.Sys_Parameters s3 on (rf.CageSize  = s3.Flag And s3.Field = 'SmallCageSize')
    LEFT JOIN IRIS_Production.dbo.Sys_Parameters s4 on (rf.Species  = s4.Flag And s4.Field = 'SmallAnimals')
    WHERE coalesce(rf.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02'
  ) t where t.chargeId is not null



INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitCost, startDate, enddate, container)
Select
    lk.rowid as chargeId,
	c.BaseCharge as unitCost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesClinical c
left join IRIS_Production.dbo.Ref_FeesProcedures r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = r.procedureName)
WHERE coalesce(c.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02'
;

INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitCost, startDate, enddate, container)
Select
	lk.rowid as chargeId,
	c.BaseCharge as unitCost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesMiscellaneous c
left join IRIS_Production.dbo.Ref_FeesProcedures r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = r.procedureName)
WHERE coalesce(c.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02'
;

--add surg fees
INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitCost, startDate, enddate, container)
Select
	lk.rowid as chargeId,
	c.SurgeryStaff as unitCost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSurgical c
left join IRIS_Production.dbo.Ref_SurgProcedure r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = (r.procedureName + ' - Staff'))
WHERE r.ProcedureID is not null AND coalesce(c.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02'

UNION ALL

Select
	lk.rowid as chargeId,
	c.NoStaff as unitCost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSurgical c
left join IRIS_Production.dbo.Ref_SurgProcedure r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = (r.procedureName + ' - No Staff'))
WHERE r.ProcedureID is not null AND coalesce(c.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02';
--EO surg fees


INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitCost, startDate, enddate, container)
select
  (SELECT rowid FROM labkey.onprc_billing.chargeableItems ci WHERE ci.name = fp.ProcedureName) as chargeId,
  pd.BaseCharge as unitCost,
  pd.DateCreated as startdate,
  pd.DateDisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

from IRIS_Production.dbo.Ref_FeesPerDiem pd
  left join IRIS_Production.dbo.Ref_FeesProcedures fp
  left join IRIS_Production.dbo.Sys_Parameters s1 ON (s1.Field = 'LocationType' and s1.Flag = HousingType)
  left join IRIS_Production.dbo.Sys_Parameters s2 ON (s2.Field = 'LocationDefinition' and s2.Flag = HousingDefinition)

    ON (
    fp.HousingDefinition = pd.HousingDefinition AND
    fp.HousingType = pd.HousingType AND
    fp.DateCreated <= coalesce(pd.DateDisabled, CURRENT_TIMESTAMP) AND
    coalesce(fp.DateDisabled, CURRENT_TIMESTAMP) >= pd.DateCreated
  )
where fp.ProcedureID is not null AND coalesce(pd.DateDisabled, CURRENT_TIMESTAMP) >= '2009/05/02'


--add lease records to charge rates
INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitCost, startDate, enddate, container)
select
	lk.rowid,
	t.unitCost,
	--lk.name,
	t.startdate,
	t.enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

FROM (
Select
	CASE
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Lease Setup Fees' THEN rf.ProcedureName
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Animal Lease Fee' THEN rf.ProcedureName + ' - TMB'
		WHEN s1.Value IS null THEN rf.ProcedureName + ' - General: ' + cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
		ELSE rf.ProcedureName + ' - ' + s1.Value + ': ' +  cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
	END as name,

	CASE WHEN rf.ProcedureName = 'Lease Setup Fees' THEN rfl.SetupFee ELSE rfl.BaseCharge END as unitCost,
	rfl.DateCreated as startdate,
	rfl.DateDisabled as enddate,
	rfl.objectid

From IRIS_Production.dbo.Ref_FeesLease rfl
      left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Flag = rfl.AgeCategory and s1.Field = 'AgeCategory')
      left join IRIS_Production.dbo.Ref_FeesProcedures rf ON (rf.ProcedureID = rfl.procedureId)

) t
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = t.name)
WHERE coalesce(t.enddate, CURRENT_TIMESTAMP) >= '2009/05/02';

--lease fee definition
TRUNCATE TABLE labkey.onprc_billing.leaseFeeDefinition;
INSERT INTO labkey.onprc_billing.leaseFeeDefinition
(chargeId, minAge, maxAge, active, assignCondition, releaseCondition, objectid)
SELECT
	lk.rowid,
	--t.name,
	t.minAge,
	t.maxAge,
	t.active,
	t.assignCondition,
	t.releaseCondition,
	t.objectid

FROM (
Select
	CASE
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Lease Setup Fees' THEN rf.ProcedureName
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Animal Lease Fee' THEN rf.ProcedureName + ' - TMB'
		WHEN s1.Value IS null THEN rf.ProcedureName + ' - General: ' + cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
		ELSE rf.ProcedureName + ' - ' + s1.Value + ': ' +  cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
	END as name,

	CASE
		WHEN rfl.AgeCategory = 1 THEN 0
		WHEN rfl.AgeCategory = 2 THEN 1
		WHEN rfl.AgeCategory = 3 THEN 4
		WHEN rfl.AgeCategory = 4 THEN 18
	END as minAge,
	CASE
		WHEN rfl.AgeCategory = 1 THEN 1
		WHEN rfl.AgeCategory = 2 THEN 4
		WHEN rfl.AgeCategory = 3 THEN 18
		WHEN rfl.AgeCategory = 4 THEN null
	END as maxAge,

	--TODO: translate
	rfl.AssignPool as assignCondition,					--Ref_Pool
	rfl.ReleasePool as releaseCondition,				--Ref_Pool
	CASE WHEN rf.ProcedureName = 'Lease Setup Fees' THEN rfl.SetupFee ELSE rfl.BaseCharge END as unitCost,
	1 as active,
	rfl.objectid

From IRIS_Production.dbo.Ref_FeesLease rfl
      left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Flag = rfl.AgeCategory and s1.Field = 'AgeCategory')
      left join IRIS_Production.dbo.Ref_FeesProcedures rf ON (rf.ProcedureID = rfl.procedureId)
where rfl.DateDisabled is null
) t
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = t.name);

--per diem definition
truncate table labkey.onprc_billing.perDiemFeeDefinition;
INSERT INTO labkey.onprc_billing.perDiemFeeDefinition (chargeId, housingType, housingDefinition, tier)
select
(SELECT rowid FROM labkey.onprc_billing.chargeableItems ci WHERE ci.name = r.ProcedureName) as chargeId,
(select rowid from labkey.ehr_lookups.lookups l WHERE l.value = s1.Value and l.set_name = 'LocationType') as HousingType,
(select rowid from labkey.ehr_lookups.lookups l WHERE l.value = CASE
    WHEN s2.Value LIKE '%Tier 1%' THEN replace(s2.value, ' Tier 1', '')
    WHEN s2.Value LIKE '%Tier 2%' THEN replace(s2.value, ' Tier 2', '')
    WHEN s2.Value LIKE '%Tier 3%' THEN replace(s2.value, ' Tier 3', '')
    ELSE s2.value
  END and l.set_name = 'LocationDefinition') as HousingDefinition,
coalesce(CASE
  WHEN s2.Value LIKE '%Tier 1%' THEN 'Tier 1'
  WHEN s2.Value LIKE '%Tier 2%' THEN 'Tier 2'
  WHEN s2.Value LIKE '%Tier 3%' THEN 'Tier 3'
  ELSE null
END, 'Tier 2') as tier

from IRIS_Production.dbo.ref_feesProcedures r
left join IRIS_Production.dbo.Sys_Parameters s1 ON (s1.Field = 'LocationType' and s1.Flag = HousingType)
left join IRIS_Production.dbo.Sys_Parameters s2 ON (s2.Field = 'LocationDefinition' and s2.Flag = HousingDefinition)
where r.HousingDefinition is not null and r.DateDisabled is null;


--SLA Fee Definition
Truncate table labkey.onprc_billing.slaPerDiemFeeDefinition;
INSERT INTO labkey.onprc_billing.slaPerDiemFeeDefinition (chargeId, CageType, CageSize, Species, active, modified, created, modifiedby, createdby)
Select
  (SELECT max(rowid) FROM onprc_billing.chargeableItems ci WHERE ci.active = 1 AND ci.name = ('Small Animal Fees - ' + s2.Value + ': ' + s3.Value + ', ' + s4.value)) as chargeId,
  s2.Value as cageType,
  s3.Value as cageSize,
  s4.Value as species,
  1 as active,
  getdate() as modified,
  getdate() as created,
  (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
  (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby

From IRIS_Production.dbo.Ref_FeesRodents rf
LEFT JOIN IRIS_Production.dbo.Sys_Parameters s2 on (rf.CageType  = s2.Flag And s2.Field = 'SmallCageType')
LEFT JOIN IRIS_Production.dbo.Sys_Parameters s3 on (rf.CageSize  = s3.Flag And s3.Field = 'SmallCageSize')
LEFT JOIN IRIS_Production.dbo.Sys_Parameters s4 on (rf.Species  = s4.Flag And s4.Field = 'SmallAnimals')
where rf.DateDisabled is null


--procedureFeeDef
truncate table labkey.onprc_billing.procedureFeeDefinition;
insert into labkey.onprc_billing.procedureFeeDefinition (procedureId, chargeId, chargetype, active, created, modified, createdBy, modifiedBy)
  select
    (select rowid from labkey.ehr_lookups.procedures p WHERE p.name = t.ProcedureName and p.category = 'Surgery') as procedureId,
    (select rowid from labkey.onprc_billing.chargeableItems p WHERE p.name = t.name) as chargeId,
    max(chargeType) as chargeType,
    MAX(t.active) as active,
    getdate() as modified,
    getdate() as created,
    (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
    (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby
  FROM (

         Select
           s.ProcedureName + ' - No Staff' as name,
           s.ProcedureName,
           'Research Staff' AS chargeType,
           CASE WHEN fs.DateDisabled is null THEN 1 else 0 END as active

         From IRIS_Production.dbo.Ref_FeesSurgical fs
           LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
         WHERE s.procedureName IS NOT NULL
         UNION ALL

         Select
           s.ProcedureName + ' - Staff' as name,
           s.ProcedureName,
           'Center Staff' AS chargeType,
           CASE WHEN fs.DateDisabled is null THEN 1 else 0 END as active

         From IRIS_Production.dbo.Ref_FeesSurgical fs
           LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
         WHERE s.procedureName IS NOT NULL
       ) t

  GROUP BY name, ProcedureName
