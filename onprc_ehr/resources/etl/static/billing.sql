/*
 * Copyright (c) 2013 LabKey Corporation
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
(name, category, active, container)

SELECT t.name, t.category, t.active, t.container FROM (

SELECT
  rfp.ProcedureName as name,
  s3.value as category,
  CASE WHEN rfp.DateDisabled IS NULL THEN 1 ELSE 0 END as active,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM IRIS_Production.dbo.Ref_FeesProcedures rfp
left join IRIS_Production.dbo.Sys_Parameters s3 on (s3.Field = 'ChargeType'and s3.Flag = rfp.ChargeType)

UNION ALL

--add ref_feesSurgical to chargeableItems
select
	t.name,
	'Surgery' as category,
	MAX(t.active) as active,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM (

Select
	s.ProcedureName + ' - No Staff' as name,
	CASE WHEN fs.DateDisabled is null THEN 1 else 0 END as active

From IRIS_Production.dbo.Ref_FeesSurgical fs
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
WHERE s.procedureName IS NOT NULL
UNION ALL

Select
	s.ProcedureName + ' - Staff' as name,
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
	'Lease Fee' as category,
	1 as active,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

FROM (
Select
	CASE
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Lease Setup Fees' THEN rf.ProcedureName
		WHEN rfl.AssignPool = 0 AND rf.ProcedureName = 'Animal Lease Fee' THEN rf.ProcedureName + ' - TMB'
		WHEN s1.Value IS null THEN rf.ProcedureName + ' - General: ' + cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
		ELSE rf.ProcedureName + ' - ' + s1.Value + ': ' +  cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
	END as name

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
(project, chargeId, unitcost, startDate, enddate, container)
SELECT
  projectId,
  (SELECT max(rowid) FROM labkey.onprc_billing.chargeableItems ci WHERE ci.name = r.ProcedureName) as chargeId,
  ChargeAmount as unitcost,
  rf.DateCreated as startDate,
  rf.DateDisabled as enddate,
  (SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container
FROM IRIS_Production.dbo.Ref_FeesSpecial rf
left join IRIS_Production.dbo.Ref_FeesProcedures r ON (rf.ProcedureID = r.ProcedureID);

INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitcost, startDate, enddate, container)
Select
	fs.ProjectID,					--Ref_ProjectsIacuc
	lk.rowid as chargeid,
	--lk.name,
	--fs.ChargeAmountStaff,
	fs.ChargeAmountNoStaff as unitcost,
	--fs.ChargeDate,
	fs.DateCreated as startdate,
	fs.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSpecialSurg fs
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = s.procedureName + ' - No Staff' AND lk.category = 'Surgery')

INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitcost, startDate, enddate, container)
Select
	fs.ProjectID,					--Ref_ProjectsIacuc
	lk.rowid as chargeid,
	--lk.name,
	fs.ChargeAmountStaff as unitcost,
	--fs.ChargeAmountNoStaff as unitcost,
	--fs.ChargeDate,
	fs.DateCreated as startdate,
	fs.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSpecialSurg fs
LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = s.procedureName + ' - Staff' AND lk.category = 'Surgery')

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
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = fp.procedureName);

--charge rates
TRUNCATE TABLE labkey.onprc_billing.chargeRates;
INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitcost, startDate, enddate, container)
Select
    lk.rowid as chargeId,
	c.BaseCharge as unitcost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesClinical c
left join IRIS_Production.dbo.Ref_FeesProcedures r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = r.procedureName);

INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitcost, startDate, enddate, container)
Select
	lk.rowid as chargeId,
	c.BaseCharge as unitcost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesMiscellaneous c
left join IRIS_Production.dbo.Ref_FeesProcedures r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = r.procedureName);

--add surg fees
INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitcost, startDate, enddate, container)
Select
	lk.rowid as chargeId,
	c.SurgeryStaff as unitcost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSurgical c
left join IRIS_Production.dbo.Ref_SurgProcedure r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = (r.procedureName + ' - Staff'))
WHERE r.ProcedureID is not null

UNION ALL

Select
	lk.rowid as chargeId,
	c.NoStaff as unitcost,
	c.DateCreated as startdate,
	c.DateDisabled as enddate,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

From IRIS_Production.dbo.Ref_FeesSurgical c
left join IRIS_Production.dbo.Ref_SurgProcedure r ON (c.ProcedureID = r.ProcedureID)
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = (r.procedureName + ' - No Staff'))
WHERE r.ProcedureID is not null;
--EO surg fees


--add lease records to charge rates
INSERT INTO labkey.onprc_billing.chargeRates
(chargeId, unitcost, startDate, enddate, container)
select
	lk.rowid,
	t.unitcost,
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

	CASE WHEN rf.ProcedureName = 'Lease Setup Fees' THEN rfl.SetupFee ELSE rfl.BaseCharge END as unitcost,
	rfl.DateCreated as startdate,
	rfl.DateDisabled as enddate,
	rfl.objectid

From IRIS_Production.dbo.Ref_FeesLease rfl
      left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Flag = rfl.AgeCategory and s1.Field = 'AgeCategory')
      left join IRIS_Production.dbo.Ref_FeesProcedures rf ON (rf.ProcedureID = rfl.procedureId)

) t
left join labkey.onprc_billing.chargeableItems lk ON (lk.name = t.name);

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
	CASE WHEN rf.ProcedureName = 'Lease Setup Fees' THEN rfl.SetupFee ELSE rfl.BaseCharge END as unitcost,
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
INSERT INTO labkey.onprc_billing.perDiemFeeDefinition (chargeId, housingType, housingDefinition)
select
(SELECT rowid FROM labkey.onprc_billing.chargeableItems ci WHERE ci.name = r.ProcedureName) as chargeId,
(select rowid from labkey.ehr_lookups.lookups l WHERE l.value = s1.Value and l.set_name = 'LocationType') as HousingType,
(select rowid from labkey.ehr_lookups.lookups l WHERE l.value = s2.Value and l.set_name = 'LocationDefinition') as HousingDefinition

from IRIS_Production.dbo.ref_feesProcedures r
left join IRIS_Production.dbo.Sys_Parameters s1 ON (s1.Field = 'LocationType' and s1.Flag = HousingType)
left join IRIS_Production.dbo.Sys_Parameters s2 ON (s2.Field = 'LocationDefinition' and s2.Flag = HousingDefinition)
where r.HousingDefinition is not null and r.DateDisabled is null;


--procedureFeeDef
truncate table labkey.onprc_billing.procedureFeeDefinition;
insert into labkey.onprc_billing.procedureFeeDefinition (procedureId, chargeId, billedby, active, created, modified, createdBy, modifiedBy)
  select
    (select rowid from labkey.ehr_lookups.procedures p WHERE p.name = t.ProcedureName) as procedureId,
    (select rowid from labkey.onprc_billing.chargeableItems p WHERE p.name = t.name) as chargeId,
    max(chargeType) as billedby,
    MAX(t.active) as active,
    getdate() as modified,
    getdate() as created,
    (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as modifiedby,
    (SELECT userid from labkey.core.principals WHERE Name = 'onprcitsupport@ohsu.edu') as createdby
  FROM (

         Select
           s.ProcedureName + ' - No Staff' as name,
           s.ProcedureName,
           'Surgery Staff' AS chargeType,
           CASE WHEN fs.DateDisabled is null THEN 1 else 0 END as active

         From IRIS_Production.dbo.Ref_FeesSurgical fs
           LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
         WHERE s.procedureName IS NOT NULL
         UNION ALL

         Select
           s.ProcedureName + ' - Staff' as name,
           s.ProcedureName,
           'No Surgery Staff' AS chargeType,
           CASE WHEN fs.DateDisabled is null THEN 1 else 0 END as active

         From IRIS_Production.dbo.Ref_FeesSurgical fs
           LEFT JOIN IRIS_Production.dbo.Ref_SurgProcedure s ON (fs.ProcedureID = s.ProcedureID)
         WHERE s.procedureName IS NOT NULL
       ) t

  GROUP BY name, ProcedureName
