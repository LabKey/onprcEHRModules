/* Returns a single row of data where the date/hour of the Mathematica ABV calculations don't match the current date or hour.
 * If there is Mathematica data from multiple hours, there will be a row of data for each hour of Mathematica data.
 * This is not expected as Mathematica should drop the _public table each hour and the ETL'd data should match.
 */
SELECT DISTINCT CAST(a.dateCreated AS DATE) AS mmaDate,
    hour(a.datecreated) AS mmaHour,
    curdate() AS currentDate,
    hour(now()) AS currentHour
FROM ONPRC_EHR.AvailableBloodVolume AS a
WHERE hour(a.dateCreated) != hour(now())
   OR CAST(a.dateCreated AS DATE) != curdate()