SELECT

  m.id,
  m.date,
  m.gestation_days as gestation_days,
TIMESTAMPADD('SQL_TSI_DAY',(p.Gestation - m.gestation_days), curdate())   as ExpectedDelivery,
m.QCState

FROM study.pregnancyConfirmation m
INNER JOIN ehr_lookups.species p on (m.Id.DataSet.demographics.species = p.common )
And m.date in (select max(s.date) from study.pregnancyConfirmation s where s.id = m.id)
And m.Id.DataSet.demographics.calculated_status.code = 'Alive'
And p.Gestation is not null
And m.outcome.birthDate is null
And m.gestation_days is not null