/*Updated:  5/2/2024 jonesga
Changes Made:  We added two fiuelds to the query as requested to show
            the rate sheet selecteed and the parameter added
Assoicated xml os NIHRateSheet.query.xml
*/
select
'NIH Rate Sheet' as RateSheetSelected,
'No Parameter'  as ParameterSelected,
category,
name,
UnitCost,
year1,
year2,
year3,
year4,
year5,
year6,
year7,
year8,
PostedDate
 from NIHRateConfig