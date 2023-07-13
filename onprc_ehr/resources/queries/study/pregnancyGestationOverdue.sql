SELECT id,
    date,
    gestation_days,
    ExpectedDelivery,
    TIMESTAMPADD('SQL_TSI_DAY',30, ExpectedDelivery)  as thirty_days_pastGestation_date
FROM pregnancyGestation
--Where gestation_days is not null