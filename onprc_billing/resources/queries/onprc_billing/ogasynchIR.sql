/*Revised : 2025-06030
        GjOnes ga
        Thsi modified the query to allow blank end dates to be evaluated
 */
 */
SELECT ogasynch.lastIndexed,
       ogasynch.modifiedBy,
       ogasynch.container,
       ogasynch.modified,
       ogasynch.created,
       ogasynch.createdBy,
       ogasynch."AGENCY AWARD NUMBER",
       ogasynch."OGA AWARD NUMBER",
       ogasynch."OGA AWARD TYPE",
       ogasynch."OGA PROJECT NUMBER",
       ogasynch.ALIAS,
       ogasynch."ALIAS ENABLED FLAG",
       ogasynch."ALIAS ENABLED FLAG_MVIndicator",
       ogasynch.faRate,
       ogasynch.Key,
       ogasynch.ORIGINATING_AGENCY_AWARD_NUM,
       ogasynch.oga_award_start_Date,
       ogasynch.oga_award_end_date,
       ir.IndirectRate AS IndirectRate -- Retrieve from the `indirectRate` tab

FROM ogasynch LEFT JOIN indirectRates ir
       ON ogasynch.oga_award_start_Date >= ir.StartDate
       AND (ogasynch.oga_award_start_Date <= ir.EndDate OR ir.EndDate IS NULL);

