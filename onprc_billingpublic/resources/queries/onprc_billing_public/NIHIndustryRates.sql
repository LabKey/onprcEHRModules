/*Updated:  5/2/2024 jonesga
Changes Made:  We added two fiuelds to the query as requested to show
            the rate sheet selecteed and the parameter added
Assoicated xml os NIHIndustryRates.query.xml
*/
PARAMETERS (MARGIN FLOAT DEFAULT .25, FARATE FLOAT DEFAULT 1)
Select
    'Industrial Rate' as RateSheetSelected,
    Margin  as MarginSelected,
    FARate as FARateSelected,
    n.category,
    n.name,
    UnitCost,
    (SUM((n.UnitCost/(1-N.subsidy))*(1+MARGIN))*FARATE )  as CurrentYear,
    (SUM((N.year1/(1-N.subsidy))*(1+MARGIN))*FARATE ) as year1,
    (SUM((N.year2/(1-N.subsidy))*(1+MARGIN))*FARATE  ) as year2,
    (SUM((N.year3/(1-N.subsidy))*(1+MARGIN))*FARATE  ) as year3,
    (SUM((N.year4/(1-N.subsidy))*(1+MARGIN))*FARATE  ) as year4,
    (SUM((N.year5/(1-N.subsidy))*(1+MARGIN))*FARATE  ) as year5,
    (SUM((N.year6/(1-N.subsidy))*(1+MARGIN))*FARATE  ) as year6,
    (SUM((N.year7/(1-N.subsidy))*(1+MARGIN))*FARATE  ) as year7,
    (SUM((N.year8/(1-N.subsidy))*(1+MARGIN))*FARATE  ) as year8


FROM NIHRateConfig n
Group by
    n.category,
    n.name,
    unitCost