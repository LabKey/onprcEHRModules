/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 * Research completed by Dr Ted Hobbs ONPRC has updated the process for calculating availaable blood
 * The new research uses the Body Condition Score of DXA Scan to determine body fat.
 *  the rule to be applied relates to Rheses Macaque Animals as follows:
 ****If a BCS score is recorded that is within the last 365 days the frolumla to be applied is
 ****TBV = (113.753 + (0.752 × BW) – (18.919 × BCS))*BW)
 ***Total Available is TBV*.125
 ****Else if either no BCS is available or it is older than 1 year, the current method based on standard Available AVolume with be Applied
 ** A second process is availbale relating to DXA Scans but these are only performed by Researach Staff and not entered into PRIME
 */

SELECT
  b.lsid,
  b.id,
  b.Species,
  b.Gender,

b.MostRecentBCS,
b.BCSDate,
b.weight as mostRecentWeight,
  b.wdate as mostRecentWeightDate,
  b.blood_draw_interval,
  b.bloodPrevious,
  b.bloodFuture,
 b.species.blood_per_kg,
round(b.bloodVolume,2) as FixedRateCalculation,
round(b.TBV,2) as TotalBloodVolume,
--round((b.TBV*.125),2) as AllowableBlood1,

 Case
	When species<> 'Rhesus Macaque'  --'Fixed Rate Process'
	    Then  round((b.species.blood_per_kg  * b.id.MostRecentWeight.MostRecentWeight * b.max_draw_pct),2)
	When
		b.DaysSinceBCS > 365
		Then   round((b.species.blood_per_kg  * b.id.MostRecentWeight.MostRecentWeight *  b.max_draw_pct),2)
	When  b.MostRecentBCS is not null
 		Then round((b.TBV * .125),2)
  Else round((b.species.blood_per_kg  * b.id.MostRecentWeight.MostRecentWeight *  b.max_draw_pct),2)
	end As AllowableBlood,

	Case
	When species<> 'Rhesus Macaque'  --'Fixed Rate Process'
	    Then
	      Case
          When (b.bloodPrevious>b.bloodFuture)
            Then
              round(((b.species.blood_per_kg  * b.id.MostRecentWeight.MostRecentWeight * b.max_draw_pct)-b.bloodPrevious),2)
            ELSE
              round(((b.species.blood_per_kg  * b.id.MostRecentWeight.MostRecentWeight * b.max_draw_pct)-b.bloodFuture),2)
          End
	    When
	    	b.DaysSinceBCS > 365
		    then
            Case
            When b.bloodPrevious > b.bloodFuture
              Then
                round(((b.species.blood_per_kg  * b.id.MostRecentWeight.MostRecentWeight * b.max_draw_pct)-b.bloodPrevious),2)
              Else
                round(((b.species.blood_per_kg  * b.id.MostRecentWeight.MostRecentWeight * b.max_draw_pct)-b.bloodFuture),2)
            End
--Available Blood is Allowable Blood minus the larger of Previous and Future
		When
			b.MostRecentBCS is not null THEN
		      Case
				When b.bloodPrevious > b.bloodFuture
              Then
                round(((b.TBV * .125)-b.bloodPrevious),2)
              Else
                round(((b.TBV * .125)-b.bloodFuture),2)
            End


--       Else




 	end As AvailableBlood,

 Case
	When species<> 'Rhesus Macaque'  Then 'FR'
	When
		b.DaysSinceBCS > 365
		Then  'FR'
	When
	  b.MostRecentBCS is not null then
		'BCS'
	Else'FR'
	end As Method


FROM (

SELECT
  d.lsid,
  d.id,
  d.species,
  d.gender,
  --NOTE: this uses date part only
  lastWeight.dateOnly as wdate,
  (SELECT AVG(w.weight) AS _expr
    FROM study.weight w
    WHERE w.id = d.id
      --NOTE: this uses date part only
      AND w.dateOnly = lastWeight.dateOnly
      AND w.qcstate.publicdata = true
  ) AS weight,
  d.species.blood_per_kg,
  d.species.max_draw_pct ,
  d.species.blood_draw_interval,
  Cast(d.species.cites_Code as Float) as SpeciesCode,
  bcs.score as MostRecentBCS,
   bcs.date as BCSDate,
  TIMESTAMPDIFF('SQL_TSI_DAY',bcs.date,Now()) as DaysSinceBCS,
  --This ca;ciates tje tt
   Case
 			when  TIMESTAMPDIFF('SQL_TSI_DAY',bcs.date,Now())  < 365 THEN round(cast (113.753 + ((0.752 *  d.id.MostRecentWeight.MostRecentWeight ) - (18.919 * bcs.score))as double),2)
 			Else (d.species.blood_per_kg  * d.id.MostRecentWeight.MostRecentWeight)
			END as TotalBloodAvailable,



  COALESCE ((
    SELECT
    SUM(bd.quantity) AS quantity
    FROM study.blood bd
    WHERE bd.id = d.id
        --NOTE: this has been changed in the DB to include penidng/non-approved draws
        AND (bd.countsAgainstVolume = true) --NOTE: this does mean non-completed past requests will count against blood
        AND bd.dateOnly > cast(TIMESTAMPADD('SQL_TSI_DAY', -1 * d.species.blood_draw_interval, now()) as date)
        AND bd.dateOnly <= cast(curdate() as date)
  ), 0) AS bloodPrevious,
-- ***************New Calculation Base ***********************************************

  -- blood volume (ml/kg)
------113.753+(0.752*Wt)- (18.919*BCS)
(113.753+(0.752 *  d.id.MostRecentWeight.MostRecentWeight ) - (18.919 * bcs.score)) as BloodVolume,

--TBV(mnl)
-----weight * Blood Volume
(d.id.MostRecentWeight.MostRecentWeight * (113.753+(0.752 *  d.id.MostRecentWeight.MostRecentWeight ) - (18.919 * bcs.score))) as TBV,
--Allowable BV
-----TBV*.125


--***********************Determines Previous and Future Blood********************************
  COALESCE ((
    SELECT
    SUM(bd.quantity) AS quantity
    FROM study.blood bd
    WHERE bd.id = d.id
        --NOTE: this has been changed to include penidng/non-approved draws
        AND (bd.countsAgainstVolume = true)
        AND bd.dateOnly < cast(TIMESTAMPADD('SQL_TSI_DAY', d.species.blood_draw_interval, curdate()) as date)
        AND bd.dateOnly >= cast(curdate() as date)
  ), 0) AS bloodFuture




FROM
    study.demographics d
    --NOTE: this uses date part only
    JOIN (SELECT w.id, MAX(dateOnly) as dateOnly FROM study.weight w WHERE w.qcstate.publicdata = true GROUP BY w.id) lastWeight ON (d.id = lastWeight.id)
    LEFT OUTER JOIN study.demographicsCurrentBCS bcs on bcs.id = d.id
WHERE d.calculated_status = 'Alive'

) b