/*Updated 2024-05-03
Added 23 columns for Rate Sheet Selected and Parameter
Update of related qview.xml and NIHRateSheet.query.xml
    Added ne columns and updated Labels for Yr66 to Yr 73
*/

PARAMETERS (ProjectFA DOUBLE DEFAULT .2)
SELECT
    'NIH Rate Reduced F&A' as RateSheetSelected,
        ProjectFA as ParameterSelected,
       n.category,
       n.name,
       n.unitcost,
       (1.475 / (1 + ProjectFA)) as NewRateCalc,
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