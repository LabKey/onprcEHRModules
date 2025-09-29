/*
 * Return a single line showing latest Mathematica ABV push and the current time, if the data is stale. Otherwise, blank.
 * Used by onprc_ehr/src/org/labkey/onprc_ehr/notification/AvailableBloodVolumeNotification.java
 */

SELECT DISTINCT
    MAX(a.DateCreated) AS latestMathematicaABV_data
FROM AvailableBloodVolume a
WHERE DateCreated < TIMESTAMPADD('SQL_TSI_MINUTE', -55, NOW())
