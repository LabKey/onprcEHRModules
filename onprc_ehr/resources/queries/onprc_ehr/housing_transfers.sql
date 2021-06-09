Select
    h.Id,
    CASE
        WHEN (Select totalClinicalTreatments from study.demographicsActiveTreatments t where h.id = t.id) > 0 THEN 'Yes'
        ELSE null
        END as ActiveClinicalTreatment,
    CASE
        WHEN (Select totalClinicalTreatments FROM study.demographicsActiveTreatments t WHERE h.id = t.id and activeTreatments LIKE '%diet%') > 0 THEN 'Yes'
        ELSE null
        END as ActiveDiets,
    h.date as InDate,
    h.room.building as Building,
    h.room.area as Area,
    h.room as Room,
    h.cage as Cage,
    h.room.housingType.value as housingType,
    h.room.housingCondition.value as housingCondition,
    h.reason as ReasonForMove,
    h.remark as Remark,
    r.totalAnimals as TotalAnimals
From study.housing h, roomUtilization_temp r
Where h.room = r.room
--   And h.date >= '03-01-2021'
And h.date >= timestampadd(SQL_TSI_DAY, -1, now())
