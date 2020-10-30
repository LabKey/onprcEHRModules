SELECT d.id,
d.species,
d.gender,
d.DaysAge,
d.MostRecentWeight as weight,
d.MostRecentWeightDate,
d.date,
d.score as bcs,
d.blood_per_kg as bpk,
d.blood_draw_interval as interval,
d.max_draw_pct  as Percentage,
Case
	When d.species <> 'Rhesus Macaque' then 'Fixed Rate by Speices'
	WHen d.score is Null  then 'Fixed Rate no BCS'
	when  TIMESTAMPDIFF('SQL_TSI_DAY',d.date,Now())  > 548  Then 'Fixed Rate  BCS out of Date'
	when d.DaysAge < 730 then 'Fixed Rate NHP Too Young'

	else 'BCS'
	End as CalcMethodReason,
Case
	When d.species <> 'Rhesus Macaque' then 'Fr'
	WHen d.score is Null  then 'fr'
	when  TIMESTAMPDIFF('SQL_TSI_DAY',d.date,Now())  > 548  Then 'fr'
	when d.DaysAge < 730 then 'Fr'

	else 'BCS'
	End as CalcMethod

FROM blooddrawDemographics d