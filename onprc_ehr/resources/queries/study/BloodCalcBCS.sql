SELECT c.id,
c.species,
c.gender,
c.DaysAge,
c.Weight,
c.MostRecentWeightDate,
c.date as BCSDate,
c.bcs as BCSScore,
c.CalcMethod,
c.bpk,
c.interval,
c.Percentage,
c.CalcMethodReason,
((c.Weight * (113.753+(0.752 *  c.Weight ) - (18.919 * c.bcs)))) as BcsTbv,
(c.bpk*c.Weight)  as StandardTBV


FROM bloodCalcCriteria c
WHere c.CalcMethod = 'BCS'