
SELECT
    t.*,
    CASE
        WHEN t.overlappingProjects IS NULL THEN 1
        -- NOTE: An assignment overlapping with TMB is not charged per diems.  If TMB is single-assigned, it pays per diem and will be caught above.
        WHEN t.tmbAssignments > 0 then 0
        WHEN t.assignedProject IS NULL AND t.overlappingProjects IS NOT NULL THEN 0
        WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN 0
        WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN (1.0 / NULLIF((t.totalOverlappingProjects + 1), 0))
        WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN 1
        WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN (1.0 / NULLIF((t.totalOverlappingResearchProjects + 1), 0))
        ELSE 1
    END as effectiveDays,
    CASE
        WHEN (t.assignedProject IS NULL AND t.overlappingProjects IS NULL) THEN 'Base Grant'
        WHEN t.overlappingProjects IS NULL then 'Single Project'
        WHEN (t.tmbAssignments > 0) THEN 'Exempt By TMB'
        WHEN (t.isTMBProject = 1 AND t.overlappingProjects IS NOT NULL) THEN 'Exempt By TMB'
        WHEN t.assignedProject IS NULL AND t.overlappingProjects IS NOT NULL THEN 'Paid By Overlapping Project'
        WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN 'Paid By Overlapping Project'
        WHEN t.ProjectType != 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN 'Multiple Resources'
        WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory NOT LIKE '%Research%' THEN 'Single Project'
        WHEN t.ProjectType = 'Research' AND t.overlappingProjectsCategory LIKE '%Research%' THEN 'Multiple Research'
        ELSE 'Unknown'
    END as category,
    CASE
        -- Catch duplicate chargeIds
        WHEN (t.perDiemFeeCount > 1) THEN NULL
        -- Use the treatmentOrder to look for BottleFed
        WHEN (t.bottleFedRecordCount > 0 AND t.researchRecordCount > 0) THEN maxPdfChargeId
        -- If this item supports infants, charge that
        WHEN (pdfChargeInfantCount > 0 AND maxPdfChargeId IS NOT NULL) THEN maxPdfChargeId
        -- Otherwise, infants are a special rate
        WHEN (perDiemAge < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.INFANT_PER_DIEM_AGE') AS INTEGER))
            THEN (SELECT ci.rowid FROM onprc_billing_public.chargeableItems ci WHERE ci.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.INFANT_PER_DIEM'))
        -- Add quarantine flags, which trump housing type
        WHEN (quarantineFlagCount > 0)
            THEN (SELECT ci.rowid FROM onprc_billing_public.chargeableItems ci WHERE ci.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.QUARANTINE_PER_DIEM'))
        -- Finally, defer to housing condition
        ELSE maxPdfChargeId
    END as chargeId,
    -- Find overlapping tier flags on that day
    coalesce((
        SELECT group_concat(DISTINCT f.flag.value) AS tier
        FROM study.flags f
        -- NOTE: allow flags that ended on this date
        WHERE f.Id = t.Id AND f.enddateCoalesced >= t.dateOnly AND f.dateOnly <= t.dateOnly AND f.flag.category = 'Housing Tier'
    ), 'Tier 2') AS tier

FROM (
    SELECT
        i2.Id,
        CAST(CAST(i2.dateOnly AS DATE) AS TIMESTAMP) AS DATE,
        i2.dateOnly @hidden,
        coalesce(a.project, (SELECT p.project FROM ehr.project p WHERE p.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_GRANT_PROJECT'))) AS project,
        a.project AS assignedProject,
        max(a.duration) AS duration,  -- should only have 1 value, no so need to include in grouping
        max(timestampdiff('SQL_TSI_DAY', d.birth, i2.dateOnly)) AS ageAtTime,
        a.project.use_Category AS ProjectType,
        count(*) AS totalAssignmentRecords,
        group_concat(DISTINCT a2.project.displayName) AS overlappingProjects,
        count(DISTINCT a2.project) AS totalOverlappingProjects,
        sum(CASE WHEN LOWER(a2.project.use_Category) = LOWER('Research') THEN 1 ELSE 0 END) as totalOverlappingResearchProjects,
        group_concat(DISTINCT a2.project.use_category) AS overlappingProjectsCategory,
        group_concat(DISTINCT a2.project.protocol) AS overlappingProtocols,
        count(h3.room) AS totalHousingRecords,
        group_concat(DISTINCT h3.room) AS rooms,
        group_concat(DISTINCT h3.cage) AS cages,
        group_concat(DISTINCT h3.objectid) AS housingRecords,
        group_concat(DISTINCT a.objectid) AS assignmentRecords,
        group_concat(DISTINCT h3.room.housingCondition.value) AS housingConditions,
        group_concat(DISTINCT h3.room.housingType.value) AS housingTypes,
        max(timestampdiff('SQL_TSI_DAY', d.birth, i2.dateOnly)) AS perDiemAge,
        count(DISTINCT pdf.chargeId) AS perDiemFeeCount,
        i2.researchRecordCount,
        i2.bottleFedRecordCount,
        count(CASE WHEN pdf.canChargeInfants = TRUE THEN 1 ELSE NULL END) AS pdfChargeInfantCount,
        max(pdf.chargeId) AS maxPdfChargeId,
        (SELECT count(*) AS c
            FROM study.flags q
            WHERE q.Id = i2.Id AND q.flag.value LIKE '%Quarantine%' AND q.dateOnly <= i2.dateOnly AND q.enddateCoalesced >= i2.dateOnly
        ) AS quarantineFlagCount,
        max(i2.startDate) AS startDate @hidden,
        count(tmb.Id) AS tmbAssignments,
        SUM(CASE WHEN a.projectName = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TMB_PROJECT') THEN 1 ELSE 0 END) AS isTMBProject

    FROM (
        -- Find all distinct animals housed at the Center each day.
        -- This is the first dataset to include all animals here, not just assigned animals.
        SELECT
            h.Id,
            i.dateOnly,
            max(h.date) AS lastHousingStart,
            min(i.startDate) AS startDate @hidden,
            count(a3.project) as researchRecordCount,
            count(t1.code) as bottleFedRecordCount
        FROM ldk.dateRange i
        JOIN study.housing h ON (h.dateOnly <= i.dateOnly AND h.enddateCoalesced >= i.dateOnly AND h.qcstate.publicdata = TRUE)
        LEFT JOIN study.assignment a3 ON a3.id = h.id AND a3.date <= i.dateOnly AND a3.endDateCoalesced > i.dateOnly AND a3.project.Use_Category LIKE '%Research%'
        LEFT JOIN study.treatment_Order t1 ON t1.id = h.id AND t1.code.meaning LIKE '%Bottle%' AND t1.date <= i.dateOnly
        GROUP BY h.Id, i.dateOnly
    ) i2

    JOIN study.demographics d ON (
        i2.Id = d.Id
    )

    -- Housing is a little tricky.  Using the query above, we want to find the max start date, on or before this day.
    -- The housingType from this location is used.
    JOIN study.housing h3 ON (h3.Id = i2.Id AND i2.lastHousingStart = h3.date AND h3.qcstate.publicdata = TRUE)

    -- Then join to any assignment record overlapping each day
    LEFT JOIN (
        SELECT
            a.lsid,
            a.id,
            a.project,
            a.project.name AS projectName,
            a.date,
            a.assignCondition,
            a.releaseCondition,
            a.projectedReleaseCondition,
            a.duration,
            a.enddate,
            a.dateOnly,
            a.enddateCoalesced,
            a.objectid
        FROM study.assignment a
        WHERE a.qcstate.publicdata = TRUE
        -- NOTE: We don't exclude 1-day assignments or treat them differently.
        -- AND a.duration > 0
    ) a ON (
        i2.Id = a.id
        AND a.dateOnly <= i2.dateOnly
        -- Assignments end at midnight, so an assignment doesn't count on the current date if it ends on it.
        -- However, we also include 1-day assignments, which *can* have the end date match the start date.
        AND (a.enddate IS NULL OR a.enddateCoalesced > i2.dateOnly OR (a.dateOnly = i2.dateOnly AND a.enddateCoalesced = i2.dateOnly))
    )

    LEFT JOIN (
        -- For each assignment, find the co-assigned projects on that day.
        SELECT
            a2.lsid,
            a2.date,
            a2.enddate,
            a2.id,
            a2.project,
            a2.dateOnly,
            a2.enddateCoalesced
        FROM study.assignment a2
        WHERE a2.qcstate.publicdata = TRUE
            -- NOTE: We don't exclude 1-day assignments or treat them differently.
            -- AND a2.duration > 1
    ) a2 ON (
        i2.id = a2.id
        AND a2.dateOnly <= i2.dateOnly
        AND a.project != a2.project
        -- Assignments end at midnight, so an assignment doesn't count on the current date if it ends on it.
        -- However, we also include 1-day assignments, which *can* have the end date match the start date.
        AND (a2.enddate IS NULL OR a2.enddateCoalesced > i2.dateOnly OR (a2.dateOnly = i2.dateOnly AND a2.enddateCoalesced = i2.dateOnly))
        AND a.lsid != a2.lsid
    )

    -- Find overlapping TMB on this date, which overrides the per diem.
    LEFT JOIN study.assignment tmb ON (
        a.id = tmb.id
        AND tmb.dateOnly <= i2.dateOnly
        AND tmb.project != a.project
        AND tmb.endDateCoalesced >= i2.dateOnly
        AND tmb.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TMB_PROJECT')
    )

    LEFT JOIN onprc_billing.perDiemFeeDefinition pdf ON (
        pdf.housingType = h3.room.housingType
        AND pdf.housingDefinition = h3.room.housingCondition
        -- Find overlapping tier flags on that day
        AND coalesce(
            (SELECT group_concat(DISTINCT f.flag.value) as tier
                FROM study.flags f
                --NOTE: allow flags that ended on this date
                WHERE f.Id = i2.Id AND f.enddateCoalesced >= i2.dateOnly AND f.dateOnly <= i2.dateOnly AND f.flag.category = 'Housing Tier'),
            'Tier 2'
        ) = pdf.tier
    )

    GROUP BY i2.dateOnly, I2.Id, a.project, a.project.use_Category, i2.researchRecordCount, i2.bottleFedRecordCount

) t