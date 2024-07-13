-- Created by: Brent Logan, 6/25/2024
-- Modified by: Kollil
SELECT
    Id,
    CAST(date as DATE) as date,
    CAST(enddate as DATE) as enddate,
    Id.assignedvet.assignedvet as AssignedVet,
    Id.curlocation.room as Room,
    frequency,
    treatmentTimes,
    code.meaning as Treatment,
    volume,
    concentration,
    amount,
    route,
    remark
FROM study.treatment_order
WHERE enddate BETWEEN curdate() AND timestampadd(SQL_TSI_DAY, 7, curdate())
  AND age(CAST(date AS DATE), CAST(enddate AS DATE), SQL_TSI_MONTH) >= 1
  AND category = 'clinical'
  AND code.meaning NOT LIKE '%bottle%'
