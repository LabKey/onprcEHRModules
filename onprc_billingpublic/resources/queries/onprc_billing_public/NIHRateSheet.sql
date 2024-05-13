/*Updated 2024-05-03
Added 23 columns for Rate Sheet Selected and Parameter
Update of related qview.xml and NIHRateSheet.query.xml
    Added ne columns and updated Labels for Yr66 to Yr 73
*/


select
'NIH Rate Sheet' as RateSheetSelected,
'No Parameter' as ParameterSelected,
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