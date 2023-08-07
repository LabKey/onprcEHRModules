PARAMETERS (MARGIN FLOAT DEFAULT .25)
Select
n.category,
n.name,
--UnitCost as CurrentYear,
(SUM((n.UnitCost/(1-N.subsidy))*1.91) )  as CurrentYear,
(SUM((N.year1/(1-N.subsidy))*1.91) ) as year1,
(SUM((N.year2/(1-N.subsidy))*1.91) ) as year2,
(SUM((N.year3/(1-N.subsidy))*1.91) ) as year3,
(SUM((N.year4/(1-N.subsidy))*1.91) ) as year4,
(SUM((N.year5/(1-N.subsidy))*1.91) ) as year5,
(SUM((N.year6/(1-N.subsidy))*1.91) ) as year6,
(SUM((N.year7/(1-N.subsidy))*1.91) ) as year7,
(SUM((N.year8/(1-N.subsidy))*1.91) ) as year8,
n.PostedDate

FROM NIHRateConfig n
Group by
n.category,
n.name,
n.postedDate