ALTER TABLE onprc_ehr_compliancedb.ComplianceProcedureReport ALTER COLUMN expired_period TYPE VARCHAR(50);
ALTER TABLE onprc_ehr_compliancedb.ComplianceProcedureReport ALTER COLUMN new_expired_period TYPE VARCHAR(50);

ALTER TABLE onprc_ehr_compliancedb.ComplianceRecentReport ALTER COLUMN expired_period TYPE VARCHAR(50);
ALTER TABLE onprc_ehr_compliancedb.ComplianceRecentReport ALTER COLUMN new_expired_period TYPE VARCHAR(50);

DROP FUNCTION IF EXISTS onprc_ehr_compliancedb.p_ComplianceProcedureOverDueSoon_Process;

-- Author:	R. Blasa
-- Created: 9-20-2024

/*
**
** 	Created by
**      Blasa  		9-20-2024     Created a storedprocedure to create a static set of data from
**                                 the ComplianceProcedureRecentTest.sql query
**
**                  1-22-2026      Fix the issues with more than one subquery results
**
**
**
*/

CREATE OR REPLACE FUNCTION onprc_ehr_compliancedb.p_ComplianceProcedureOverDueSoon_Process()
RETURNS integer AS $$
BEGIN
    -- Reset Reporting table
    DELETE FROM onprc_ehr_compliancedb.ComplianceProcedureReport;

    INSERT INTO onprc_ehr_compliancedb.ComplianceProcedureReport
    (
        requirementname,
        employeeid,
        unit,
        category,
        trackingflag,
        email,
        lastname,
        firstname,
        host,
        supervisor,
        trainee_type,
        requirement_name_type,
        times_completed,
        expired_period,
        new_expired_Period,
        mostrecentcompleted_date,
        comment,
        snooze_date,
        months_until_renewal
    )
    SELECT
        b.requirementname,
        a.employeeid,
        string_agg(a.unit, chr(10)) AS unit,
        string_agg(a.category, chr(10)) AS category,
        string_agg(b.trackingflag, chr(10)) AS trackingflag,
        (SELECT h.email FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS email,
        (SELECT h.lastname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS lastname,
        (SELECT h.firstname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS firstname,
        (SELECT h.majorudds FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS host,
        (SELECT h.supervisor FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS supervisor,
        (SELECT h.type FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS trainee_type,
        (SELECT string_agg(h.type::text, chr(10)) FROM ehr_compliancedb.Requirements h WHERE h.requirementname = b.requirementname) AS requirement_type,
        (SELECT count(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid) AS times_Completed,
        (SELECT string_agg(k.expireperiod::text, chr(10)) FROM ehr_compliancedb.Requirements k WHERE k.requirementname = b.requirementname) AS ExpiredPeriod,
        (
            SELECT ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
            FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
            WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
            GROUP BY tt.expireperiod, tt.reviewdate
            HAVING (COALESCE(tt.expireperiod, 0)) > ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
               AND (tt.reviewdate IS NOT NULL)
        ) AS NewExpirePeriod,
        (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid) AS mostrecentcompleted_date,
        (
            SELECT string_agg(DISTINCT yy.comment, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = b.requirementname AND yy.employeeid = a.employeeid
        ) AS comment,
        (
            SELECT string_agg(DISTINCT yy.snooze_date::text, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = b.requirementname AND yy.employeeid = a.employeeid
        ) AS snooze_date,
        CAST(
            CASE
                WHEN (SELECT max(st.date) FROM ehr_compliancedb.completiondates st WHERE st.requirementname = b.requirementname AND st.employeeid = a.employeeid) IS NULL THEN 0
                WHEN (SELECT COALESCE(tt.expireperiod, 0) FROM ehr_compliancedb.requirements tt WHERE tt.requirementname = b.requirementname GROUP BY tt.expireperiod) = 0 THEN NULL
                WHEN (
                    SELECT count(*)
                    FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                    WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                    GROUP BY tt.expireperiod, tt.reviewdate
                    HAVING tt.reviewdate > max(pq.date)
                ) > 0 THEN
                    (
                        SELECT (((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
                                - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date))))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod, tt.reviewdate
                        HAVING tt.reviewdate > max(pq.date)
                    )
                ELSE
                    (
                        SELECT COALESCE(tt.expireperiod, 0) - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date)))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod
                    )
            END AS DOUBLE PRECISION
        ) AS MonthsUntilRenewal
    FROM ehr_compliancedb.employeeperunit a, ehr_compliancedb.requirementspercategory b
    WHERE (a.unit = b.unit OR a.category = b.category)
      AND b.requirementname NOT IN (SELECT DISTINCT t.requirementname FROM ehr_compliancedb.employeerequirementexemptions t WHERE a.employeeid = t.employeeid AND b.requirementname = t.requirementname)
      AND a.employeeid IN (SELECT p.employeeid FROM ehr_compliancedb.employees p WHERE a.employeeid = p.employeeid AND p.enddate IS NULL)
      AND b.requirementname IN (SELECT q.requirementname FROM ehr_compliancedb.Requirements q WHERE q.requirementname = b.requirementname AND q.dateDisabled IS NULL)
    GROUP BY b.requirementname, a.employeeid

    UNION

    SELECT
        a.requirementname,
        a.employeeid,
        NULL AS unit,
        NULL AS category,
        'None' AS trackingflag,
        (SELECT h.email FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS email,
        (SELECT h.lastname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS lastname,
        (SELECT h.firstname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS firstname,
        (SELECT h.majorudds FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS host,
        (SELECT h.supervisor FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS supervisor,
        (SELECT h.type FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS trainee_type,
        (SELECT string_agg(h.type::text, chr(10)) FROM ehr_compliancedb.Requirements h WHERE h.requirementname = a.requirementname) AS requirement_type,
        (SELECT count(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid) AS timesCompleted,
        (SELECT string_agg(k.expireperiod::text, chr(10)) FROM ehr_compliancedb.Requirements k WHERE k.requirementname = a.requirementname) AS ExpiredPeriod,
        (
            SELECT ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
            FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
            WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
            GROUP BY tt.expireperiod, tt.reviewdate
            HAVING (COALESCE(tt.expireperiod, 0)) > ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
               AND (tt.reviewdate IS NOT NULL)
        ) AS NewExpirePeriod,
        (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid) AS MostRecentDate,
        (
            SELECT string_agg(DISTINCT yy.comment, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = a.requirementname AND yy.employeeid = a.employeeid
        ) AS comment,
        (
            SELECT string_agg(DISTINCT yy.snooze_date::text, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = a.requirementname AND yy.employeeid = a.employeeid
        ) AS snooze_date,
        CAST(
            CASE
                WHEN (SELECT max(st.date) FROM ehr_compliancedb.completiondates st WHERE st.requirementname = a.requirementname AND st.employeeid = a.employeeid) IS NULL THEN 0
                WHEN (SELECT COALESCE(tt.expireperiod, 0) FROM ehr_compliancedb.requirements tt WHERE tt.requirementname = a.requirementname GROUP BY tt.expireperiod) = 0 THEN NULL
                WHEN (
                    SELECT count(*)
                    FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                    WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                    GROUP BY tt.expireperiod, tt.reviewdate
                    HAVING tt.reviewdate > max(pq.date)
                ) > 0 THEN
                    (
                        SELECT (((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
                                - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date))))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod, tt.reviewdate
                        HAVING tt.reviewdate > max(pq.date)
                    )
                ELSE
                    (
                        SELECT COALESCE(tt.expireperiod, 0) - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date)))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod
                    )
            END AS DOUBLE PRECISION
        ) AS MonthsUntilRenewal
    FROM ehr_compliancedb.completiondates a
    WHERE a.requirementname NOT IN (
        SELECT DISTINCT h.requirementname
        FROM ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h
        WHERE (k.unit = h.unit OR k.category = h.category) AND a.employeeid = k.employeeid
    )
      AND a.requirementname NOT IN (SELECT DISTINCT t.requirementname FROM ehr_compliancedb.employeerequirementexemptions t WHERE a.employeeid = t.employeeid AND a.requirementname = t.requirementname)
      AND a.employeeid IN (SELECT p.employeeid FROM ehr_compliancedb.employees p WHERE a.employeeid = p.employeeid AND p.enddate IS NULL)
      AND a.requirementname IN (SELECT q.requirementname FROM ehr_compliancedb.Requirements q WHERE q.requirementname = a.requirementname AND q.dateDisabled IS NULL)
    GROUP BY a.requirementname, a.employeeid

    UNION

    -- Additional requirements for employees that have not completed training, but is required
    SELECT
        j.requirementname,
        j.employeeid,
        NULL AS unit,
        NULL AS category,
        string_agg(j.trackingflag, chr(10)) AS trackingflag,
        (SELECT h.email FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS email,
        (SELECT h.lastname FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS lastname,
        (SELECT h.firstname FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS firstname,
        (SELECT h.majorudds FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS host,
        (SELECT h.supervisor FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS supervisor,
        (SELECT h.type FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS trainee_type,
        (SELECT string_agg(h.type::text, chr(10)) FROM ehr_compliancedb.Requirements h WHERE h.requirementname = j.requirementname) AS requirement_type,
        0 AS timesCompleted,
        (SELECT string_agg(k.expireperiod::text, chr(10)) FROM ehr_compliancedb.Requirements k WHERE k.requirementname = j.requirementname) AS ExpiredPeriod,
        (
            SELECT ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
            FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
            WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
            GROUP BY tt.expireperiod, tt.reviewdate
            HAVING (COALESCE(tt.expireperiod, 0)) > ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
               AND (tt.reviewdate IS NOT NULL)
        ) AS NewExpirePeriod,
        NULL AS MostRecentDate,
        '' AS comment,
        NULL AS snooze_date,
        CAST(
            CASE
                WHEN (SELECT max(st.date) FROM ehr_compliancedb.completiondates st WHERE st.requirementname = j.requirementname AND st.employeeid = j.employeeid) IS NULL THEN 0
                WHEN (SELECT COALESCE(tt.expireperiod, 0) FROM ehr_compliancedb.requirements tt WHERE tt.requirementname = j.requirementname GROUP BY tt.expireperiod) = 0 THEN NULL
                WHEN (
                    SELECT count(*)
                    FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                    WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
                    GROUP BY tt.expireperiod, tt.reviewdate
                    HAVING tt.reviewdate > max(pq.date)
                ) > 0 THEN
                    (
                        SELECT (((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
                                - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date))))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
                        GROUP BY tt.expireperiod, tt.reviewdate
                        HAVING tt.reviewdate > max(pq.date)
                    )
                ELSE
                    (
                        SELECT COALESCE(tt.expireperiod, 0) - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date)))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
                        GROUP BY tt.expireperiod
                    )
            END AS DOUBLE PRECISION
        ) AS MonthsUntilRenewal
    FROM onprc_ehr_compliancedb.RequirementsPerEmployee j
    WHERE j.employeeid IN (SELECT p.employeeid FROM ehr_compliancedb.employees p WHERE j.employeeid = p.employeeid AND p.enddate IS NULL)
      AND j.requirementname IN (SELECT q.requirementname FROM ehr_compliancedb.Requirements q WHERE q.requirementname = j.requirementname AND q.dateDisabled IS NULL)
      AND j.requirementname NOT IN (
          SELECT DISTINCT h.requirementname
          FROM ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h
          WHERE (k.unit = h.unit OR k.category = h.category) AND j.employeeid = k.employeeid
      )
      AND j.requirementname NOT IN (SELECT DISTINCT t.requirementname FROM ehr_compliancedb.employeerequirementexemptions t WHERE j.employeeid = t.employeeid AND j.requirementname = t.requirementname)
      AND j.requirementname NOT IN (SELECT DISTINCT k.requirementname FROM ehr_compliancedb.completiondates k WHERE k.employeeid = j.employeeid)
    GROUP BY j.requirementname, j.employeeid
    ORDER BY employeeid, requirementname, mostrecentcompleted_date DESC;

    RETURN 0;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 1;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS onprc_ehr_compliancedb.p_ComplianceProcedureOverDueSoon_Process;

-- Author:	R. Blasa
-- Created: 9-20-2024

/*
**
** 	Created by
**      Blasa  		9-20-2024     Created a storedprocedure to create a static set of data from
**                                 the ComplianceRecentTest.sql query
**
**                   1-22-2026   Fix the issues with more than one subquery results
**
**
*/

CREATE OR REPLACE FUNCTION onprc_ehr_compliancedb.p_ComplianceRecentOverDueSoon_Process()
RETURNS integer AS $$
BEGIN
    -- Reset Reporting table
    DELETE FROM onprc_ehr_compliancedb.ComplianceRecentReport;

    INSERT INTO onprc_ehr_compliancedb.ComplianceRecentReport
    (
        requirementname,
        employeeid,
        unit,
        category,
        trackingflag,
        email,
        lastname,
        firstname,
        host,
        supervisor,
        trainee_type,
        requirement_name_type,
        times_completed,
        expired_period,
        new_expired_Period,
        mostrecentcompleted_date,
        comment,
        snooze_date,
        months_until_renewal
    )
    SELECT
        b.requirementname,
        a.employeeid,
        string_agg(a.unit, chr(10)) AS unit,
        string_agg(a.category, chr(10)) AS category,
        string_agg(b.trackingflag, chr(10)) AS trackingflag,
        (SELECT h.email FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS email,
        (SELECT h.lastname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS lastname,
        (SELECT h.firstname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS firstname,
        (SELECT h.majorudds FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS host,
        (SELECT h.supervisor FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS supervisor,
        (SELECT h.type FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS trainee_type,
        (SELECT string_agg(h.type::text, chr(10)) FROM ehr_compliancedb.Requirements h WHERE h.requirementname = b.requirementname) AS requirement_type,
        (SELECT count(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid) AS times_Completed,
        (SELECT string_agg(k.expireperiod::text, chr(10)) FROM ehr_compliancedb.Requirements k WHERE k.requirementname = b.requirementname) AS ExpiredPeriod,
        (
            SELECT ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
            FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
            WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
            GROUP BY tt.expireperiod, tt.reviewdate
            HAVING (COALESCE(tt.expireperiod, 0)) > ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
               AND (tt.reviewdate IS NOT NULL)
        ) AS NewExpirePeriod,
        (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid) AS mostrecentcompleted_date,
        (
            SELECT string_agg(DISTINCT yy.comment, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = b.requirementname AND yy.employeeid = a.employeeid
        ) AS comment,
        (
            SELECT string_agg(DISTINCT yy.snooze_date::text, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = b.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = b.requirementname AND yy.employeeid = a.employeeid
        ) AS snooze_date,
        CAST(
            CASE
                WHEN (SELECT max(st.date) FROM ehr_compliancedb.completiondates st WHERE st.requirementname = b.requirementname AND st.employeeid = a.employeeid) IS NULL THEN 0
                WHEN (SELECT COALESCE(tt.expireperiod, 0) FROM ehr_compliancedb.requirements tt WHERE tt.requirementname = b.requirementname GROUP BY tt.expireperiod) = 0 THEN NULL
                WHEN (
                    SELECT count(*)
                    FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                    WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                    GROUP BY tt.expireperiod, tt.reviewdate
                    HAVING tt.reviewdate > max(pq.date)
                ) > 0 THEN
                    (
                        SELECT (((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
                                - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date))))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod, tt.reviewdate
                        HAVING tt.reviewdate > max(pq.date)
                    )
                ELSE
                    (
                        SELECT COALESCE(tt.expireperiod, 0) - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date)))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = b.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod
                    )
            END AS DOUBLE PRECISION
        ) AS MonthsUntilRenewal
    FROM ehr_compliancedb.employeeperunit a, ehr_compliancedb.requirementspercategory b
    WHERE (a.unit = b.unit OR a.category = b.category)
      AND b.requirementname NOT IN (SELECT DISTINCT t.requirementname FROM ehr_compliancedb.employeerequirementexemptions t WHERE a.employeeid = t.employeeid AND b.requirementname = t.requirementname)
      AND a.employeeid IN (SELECT p.employeeid FROM ehr_compliancedb.employees p WHERE a.employeeid = p.employeeid AND p.enddate IS NULL)
      AND b.requirementname IN (SELECT q.requirementname FROM ehr_compliancedb.Requirements q WHERE q.requirementname = b.requirementname AND q.dateDisabled IS NULL)
    GROUP BY b.requirementname, a.employeeid

    UNION

    SELECT
        a.requirementname,
        a.employeeid,
        NULL AS unit,
        NULL AS category,
        'None' AS trackingflag,
        (SELECT h.email FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS email,
        (SELECT h.lastname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS lastname,
        (SELECT h.firstname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS firstname,
        (SELECT h.majorudds FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS host,
        (SELECT h.supervisor FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS supervisor,
        (SELECT h.type FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS trainee_type,
        (SELECT string_agg(h.type::text, chr(10)) FROM ehr_compliancedb.Requirements h WHERE h.requirementname = a.requirementname) AS requirement_type,
        (SELECT count(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid) AS timesCompleted,
        (SELECT string_agg(k.expireperiod::text, chr(10)) FROM ehr_compliancedb.Requirements k WHERE k.requirementname = a.requirementname) AS ExpiredPeriod,
        (
            SELECT ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
            FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
            WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
            GROUP BY tt.expireperiod, tt.reviewdate
            HAVING (COALESCE(tt.expireperiod, 0)) > ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
               AND (tt.reviewdate IS NOT NULL)
        ) AS NewExpirePeriod,
        (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid) AS MostRecentDate,
        (
            SELECT string_agg(DISTINCT yy.comment, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = a.requirementname AND yy.employeeid = a.employeeid
        ) AS comment,
        (
            SELECT string_agg(DISTINCT yy.snooze_date::text, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = a.requirementname AND yy.employeeid = a.employeeid
        ) AS snooze_date,
        CAST(
            CASE
                WHEN (SELECT max(st.date) FROM ehr_compliancedb.completiondates st WHERE st.requirementname = a.requirementname AND st.employeeid = a.employeeid) IS NULL THEN 0
                WHEN (SELECT COALESCE(tt.expireperiod, 0) FROM ehr_compliancedb.requirements tt WHERE tt.requirementname = a.requirementname GROUP BY tt.expireperiod) = 0 THEN NULL
                WHEN (
                    SELECT count(*)
                    FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                    WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                    GROUP BY tt.expireperiod, tt.reviewdate
                    HAVING tt.reviewdate > max(pq.date)
                ) > 0 THEN
                    (
                        SELECT (((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
                                - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date))))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod, tt.reviewdate
                        HAVING tt.reviewdate > max(pq.date)
                    )
                ELSE
                    (
                        SELECT COALESCE(tt.expireperiod, 0) - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date)))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod
                    )
            END AS DOUBLE PRECISION
        ) AS MonthsUntilRenewal
    FROM ehr_compliancedb.completiondates a
    WHERE a.requirementname NOT IN (
        SELECT DISTINCT h.requirementname
        FROM ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h
        WHERE (k.unit = h.unit OR k.category = h.category) AND a.employeeid = k.employeeid
    )
      AND a.requirementname NOT IN (SELECT DISTINCT t.requirementname FROM ehr_compliancedb.employeerequirementexemptions t WHERE a.employeeid = t.employeeid AND a.requirementname = t.requirementname)
      AND a.employeeid IN (SELECT p.employeeid FROM ehr_compliancedb.employees p WHERE a.employeeid = p.employeeid AND p.enddate IS NULL)
      AND a.requirementname IN (SELECT q.requirementname FROM ehr_compliancedb.Requirements q WHERE q.requirementname = a.requirementname AND q.dateDisabled IS NULL)
    GROUP BY a.requirementname, a.employeeid

    UNION

    -- Training that was completed by as an employee training exemptions, and at least completed one, or more times
    SELECT
        a.requirementname,
        a.employeeid,
        NULL AS unit,
        NULL AS category,
        'No' AS trackingflag,
        (SELECT h.email FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS email,
        (SELECT h.lastname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS lastname,
        (SELECT h.firstname FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS firstname,
        (SELECT h.majorudds FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS host,
        (SELECT h.supervisor FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS supervisor,
        (SELECT h.type FROM ehr_compliancedb.employees h WHERE h.employeeid = a.employeeid) AS trainee_type,
        (SELECT string_agg(h.type::text, chr(10)) FROM ehr_compliancedb.Requirements h WHERE h.requirementname = a.requirementname) AS requirement_type,
        (SELECT count(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid) AS timesCompleted,
        (SELECT string_agg(k.expireperiod::text, chr(10)) FROM ehr_compliancedb.Requirements k WHERE k.requirementname = a.requirementname) AS ExpiredPeriod,
        (
            SELECT ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
            FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
            WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
            GROUP BY tt.expireperiod, tt.reviewdate
            HAVING (COALESCE(tt.expireperiod, 0)) > ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
               AND (tt.reviewdate IS NOT NULL)
        ) AS NewExpirePeriod,
        (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid) AS MostRecentDate,
        (
            SELECT string_agg(DISTINCT yy.comment, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = a.requirementname AND yy.employeeid = a.employeeid
        ) AS comment,
        (
            SELECT string_agg(DISTINCT yy.snooze_date::text, chr(10))
            FROM ehr_compliancedb.completiondates yy
            WHERE yy.date IN (SELECT max(zz.date) FROM ehr_compliancedb.completiondates zz WHERE zz.requirementname = a.requirementname AND zz.employeeid = a.employeeid)
              AND yy.requirementname = a.requirementname AND yy.employeeid = a.employeeid
        ) AS snooze_date,
        CAST(
            CASE
                WHEN (SELECT max(st.date) FROM ehr_compliancedb.completiondates st WHERE st.requirementname = a.requirementname AND st.employeeid = a.employeeid) IS NULL THEN 0
                WHEN (SELECT COALESCE(tt.expireperiod, 0) FROM ehr_compliancedb.requirements tt WHERE tt.requirementname = a.requirementname GROUP BY tt.expireperiod) = 0 THEN NULL
                WHEN (
                    SELECT count(*)
                    FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                    WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                    GROUP BY tt.expireperiod, tt.reviewdate
                    HAVING tt.reviewdate > max(pq.date)
                ) > 0 THEN
                    (
                        SELECT (((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
                                - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date))))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod, tt.reviewdate
                        HAVING tt.reviewdate > max(pq.date)
                    )
                ELSE
                    (
                        SELECT COALESCE(tt.expireperiod, 0) - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date)))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = a.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = a.employeeid
                        GROUP BY tt.expireperiod
                    )
            END AS DECIMAL
        ) AS MonthsUntilRenewal
    FROM ehr_compliancedb.employeerequirementexemptions a
    WHERE a.employeeid IN (SELECT p.employeeid FROM ehr_compliancedb.employees p WHERE a.employeeid = p.employeeid AND p.enddate IS NULL)
      AND a.requirementname IN (SELECT q.requirementname FROM ehr_compliancedb.Requirements q WHERE q.requirementname = a.requirementname AND q.dateDisabled IS NULL)
    GROUP BY a.requirementname, a.employeeid

    UNION

    -- Additional requirements for employees that have not completed training, but is required
    SELECT
        j.requirementname,
        j.employeeid,
        NULL AS unit,
        NULL AS category,
        string_agg(j.trackingflag, chr(10)) AS trackingflag,
        (SELECT h.email FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS email,
        (SELECT h.lastname FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS lastname,
        (SELECT h.firstname FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS firstname,
        (SELECT h.majorudds FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS host,
        (SELECT h.supervisor FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS supervisor,
        (SELECT h.type FROM ehr_compliancedb.employees h WHERE h.employeeid = j.employeeid) AS trainee_type,
        (SELECT string_agg(h.type::text, chr(10)) FROM ehr_compliancedb.Requirements h WHERE h.requirementname = j.requirementname) AS requirement_type,
        0 AS timesCompleted,
        (SELECT string_agg(k.expireperiod::text, chr(10)) FROM ehr_compliancedb.Requirements k WHERE k.requirementname = j.requirementname) AS ExpiredPeriod,
        (
            SELECT ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
            FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
            WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
            GROUP BY tt.expireperiod, tt.reviewdate
            HAVING (COALESCE(tt.expireperiod, 0)) > ((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
               AND (tt.reviewdate IS NOT NULL)
        ) AS NewExpirePeriod,
        NULL AS MostRecentDate,
        '' AS comment,
        NULL AS snooze_date,
        CAST(
            CASE
                WHEN (SELECT max(st.date) FROM ehr_compliancedb.completiondates st WHERE st.requirementname = j.requirementname AND st.employeeid = j.employeeid) IS NULL THEN 0
                WHEN (SELECT COALESCE(tt.expireperiod, 0) FROM ehr_compliancedb.requirements tt WHERE tt.requirementname = j.requirementname GROUP BY tt.expireperiod) = 0 THEN NULL
                WHEN (
                    SELECT count(*)
                    FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                    WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
                    GROUP BY tt.expireperiod, tt.reviewdate
                    HAVING tt.reviewdate > max(pq.date)
                ) > 0 THEN
                    (
                        SELECT (((EXTRACT(YEAR FROM tt.reviewdate) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM tt.reviewdate) - EXTRACT(MONTH FROM max(pq.date)))
                                - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date))))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
                        GROUP BY tt.expireperiod, tt.reviewdate
                        HAVING tt.reviewdate > max(pq.date)
                    )
                ELSE
                    (
                        SELECT COALESCE(tt.expireperiod, 0) - ((EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM max(pq.date))) * 12 + EXTRACT(MONTH FROM now()) - EXTRACT(MONTH FROM max(pq.date)))
                        FROM ehr_compliancedb.requirements tt, ehr_compliancedb.completiondates pq
                        WHERE tt.requirementname = j.requirementname AND pq.requirementname = tt.requirementname AND pq.employeeid = j.employeeid
                        GROUP BY tt.expireperiod
                    )
            END AS DOUBLE PRECISION
        ) AS MonthsUntilRenewal
    FROM onprc_ehr_compliancedb.RequirementsPerEmployee j
    WHERE j.employeeid IN (SELECT p.employeeid FROM ehr_compliancedb.employees p WHERE j.employeeid = p.employeeid AND p.enddate IS NULL)
      AND j.requirementname IN (SELECT q.requirementname FROM ehr_compliancedb.Requirements q WHERE q.requirementname = j.requirementname AND q.dateDisabled IS NULL)
      AND j.requirementname NOT IN (
          SELECT DISTINCT h.requirementname
          FROM ehr_compliancedb.employeeperunit k, ehr_compliancedb.requirementspercategory h
          WHERE (k.unit = h.unit OR k.category = h.category) AND j.employeeid = k.employeeid
      )
      AND j.requirementname NOT IN (SELECT DISTINCT t.requirementname FROM ehr_compliancedb.employeerequirementexemptions t WHERE j.employeeid = t.employeeid AND j.requirementname = t.requirementname)
      AND j.requirementname NOT IN (SELECT DISTINCT k.requirementname FROM ehr_compliancedb.completiondates k WHERE k.employeeid = j.employeeid)
    GROUP BY j.requirementname, j.employeeid
    ORDER BY employeeid, requirementname, mostrecentcompleted_date DESC;

    RETURN 0;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 1;
END;
$$ LANGUAGE plpgsql;
