/*2024-05-02  jonesga
Update for Year 65 as Current
    Associated xml was completed with new labels and addition of 2 fields
    to identify the rate sheet selected and the parameters*/

PARAMETERS (ProjectFA DOUBLE DEFAULT .2)
SELECT 'Reduced F&A Sheet' as RateSheetSelected,
       ProjectFA  as ParameterSelected,
       n.category,
       n.name,
       n.unitcost,
       (1.47 / (1 + ProjectFA)) as NewRateCalc,
       (n.UnitCost *(1.475 / (1 + ProjectFA))) as CurrentYear,
       (n.year1 *(1.475 / (1 + ProjectFA))) as Year1,
       (n.year2 *(1.475 / (1 + ProjectFA))) as Year2,
       (n.year3 *(1.475 / (1 + ProjectFA))) as Year3,
       (n.year4 *(1.475 / (1 + ProjectFA))) as Year4,
       (n.year5 *(1.475 / (1 + ProjectFA))) as Year5,
       (n.year6 *(1.475 / (1 + ProjectFA))) as Year6,
       (n.year7 *(1.475 / (1 + ProjectFA))) as Year7,
       (n.year8 *(1.475 / (1 + ProjectFA))) as Year8,
       n.PostedDate
FROM NIHRateConfig n