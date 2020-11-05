SELECT c.id,
c.species,
c.gender,
c.DaysAge,
c.weight,
c.MostRecentWeightDate,
c.date,
c.bcs,
c.bpk,
c.interval,
c.Percentage,
c.CalcMethodReason,
c.CalcMethod,
(Select fr.totalBloodVolume  from study,bloodcalcFixedRate fr where c.id = fr.id) as TotalBloodVolumeFR,
(Select b.bcstbv from study.Bloodcalcbcs b where c.id = b.id) as TotalBloodVolumeBCS,

CAST(
Case
	When c.CalcMethod = 'fr' then
		(Select (fr.totalBloodVolume * c.percentage) as frtba from study,bloodcalcFixedRate fr where c.id = fr.id)
	When c.calcMethod = 'BCS' then
		(Select (b.bcstbv * c.percentage) as bcstba from study.Bloodcalcbcs b where c.id = b.id)
	End AS DOUBLE) as ABV
FROM bloodCalcCriteria c