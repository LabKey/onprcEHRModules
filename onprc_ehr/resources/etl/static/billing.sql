--chargableItems, only importing new items
INSERT INTO labkey.onprc_billing.chargableItems
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

--add ref_feesSurgical to chargableItems
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
--add lease fees to chargableItems
SELECT
	name,
	'Lease Fee' as category,
	1 as active,
	(SELECT c.entityid from labkey.core.containers c LEFT JOIN labkey.core.Containers c2 on (c.Parent = c2.EntityId) WHERE c.name = 'EHR' and c2.name = 'ONPRC') as container

FROM (
Select
	CASE
		WHEN s1.Value IS null THEN rf.ProcedureName + ' - General: ' + cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
		ELSE rf.ProcedureName + ' - ' + s1.Value + ': ' +  cast(rfl.AssignPool AS nvarchar) + '->' + cast(rfl.ReleasePool AS nvarchar)
	END as name

From IRIS_Production.dbo.Ref_FeesLease rfl
      left join IRIS_Production.dbo.Sys_Parameters s1 on (s1.Flag = rfl.AgeCategory and s1.Field = 'AgeCategory')
      left join IRIS_Production.dbo.Ref_FeesProcedures rf ON (rf.ProcedureID = rfl.procedureId)
      left join labkey.onprc_billing.chargableItems lk ON (lk.name = rf.procedureName)
where rfl.DateDisabled is null
) t
GROUP BY name

--TODO: procedure fee definition

) t
LEFT JOIN labkey.onprc_billing.chargableItems ci ON (ci.name = t.name)
WHERE ci.name IS NULL;




--chargeableExemptions
TRUNCATE TABLE labkey.onprc_billing.chargeRateExemptions;
INSERT INTO labkey.onprc_billing.chargeRateExemptions
(project, chargeId, unitcost, startDate, enddate, container)
SELECT
  projectId,
  (SELECT max(rowid) FROM labkey.onprc_billing.chargableItems ci WHERE ci.name = r.ProcedureName) as chargeId,
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
left join labkey.onprc_billing.chargableItems lk ON (lk.name = s.procedureName + ' - No Staff' AND lk.category = 'Surgery')

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
left join labkey.onprc_billing.chargableItems lk ON (lk.name = s.procedureName + ' - Staff' AND lk.category = 'Surgery')

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
left join labkey.onprc_billing.chargableItems lk ON (lk.name = fp.procedureName);

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
left join labkey.onprc_billing.chargableItems lk ON (lk.name = r.procedureName);

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
left join labkey.onprc_billing.chargableItems lk ON (lk.name = r.procedureName);

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
left join labkey.onprc_billing.chargableItems lk ON (lk.name = t.name);

--lease fee definition
TRUNCATE TABLE labkey.onprc_billing.leaseFeeDefinition;
INSERT INTO labkey.onprc_billing.leaseFeeDefinition
(chargeId, minAge, maxAge, assignCondition, releaseCondition, active, objectid)
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
left join labkey.onprc_billing.chargableItems lk ON (lk.name = t.name);

--per diem definition
INSERT INTO labkey.onprc_billing.perDiemFeeDefinition (chargeId, housingDefinition, housingType)
select
(SELECT rowid FROM labkey.onprc_billing.chargableItems ci WHERE ci.name = r.ProcedureName) as chargeId,
HousingDefinition,
HousingType

from IRIS_Production.dbo.ref_feesProcedures r
where HousingDefinition is not null and DateDisabled is null;
