/*2024-05-02  jonesga
Update for Year 65 as Current
    Associated xml was completed with new labels and addition of 2 fields
    to identify the rate sheet selected and the parameters*/
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