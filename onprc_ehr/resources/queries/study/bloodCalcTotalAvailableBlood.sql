SELECT a.id,
a.species,
a.gender,
a.DaysAge,
a.weight,
a.MostRecentWeightDate,
a.date,
a.bcs,
a.bpk,
a.interval,
a.Percentage,
a.CalcMethodReason,
a.CalcMethod,
a.ABV as TotalAllowableBlood,
fp.PreviousDraws,
fp.futureDraws,
Case
	When fp.PReviousDraws > fp.futureDraws then (a.ABV - fp.PReviousDraws)
	When fp.FutureDraws > fp.PReviousDraws  then (a.abv - fp.futureDraws)
	else ABV
	End as TotalAvailableBlood
FROM bloodCalcTotalAllowableBlood a left outer join bloodCalcPastandFuture fp on a.id = fp.id