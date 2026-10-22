/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- Modified by Kollil in Sep, 2026 - Removed any empty requestor data
SELECT
    requestorid,
    requestorid.lastName AS RequestorLastname,
    SUM(
            CASE
                WHEN confirmationnum IS NULL
                    AND datecancelled IS NULL
                    THEN 1
                ELSE 0
                END
    ) AS pendingorders,
    COUNT(rowid) AS numberoforders
FROM PurchaseOrderDetails
WHERE requestor IS NOT NULL
  AND requestor <> ''
GROUP BY
    requestorid,
    requestorid.lastName