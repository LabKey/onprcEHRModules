/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
PARAMETERS(DATE_INTERVAL INTEGER, MAX_DRAW_PCT DOUBLE, ML_PER_KG DOUBLE)

SELECT
t.id,
t.date,
cast(t.quantity as double) as quantity,
t.species,
ML_PER_KG,
DATE_INTERVAL,
MAX_DRAW_PCT,
t.mostRecentWeight,
t.mostRecentWeightDate,
cast(t.allowableBlood as double) as maxAllowableBlood,
cast(t.bloodPrevious as double) as bloodPrevious,
cast((t.allowableBlood - t.bloodPrevious) as double) as allowablePrevious,

cast(t.bloodFuture as double) as bloodFuture,
cast((t.allowableBlood - t.bloodFuture) as double) as allowableFuture,

--if the draw is historic, always consider previous draws only.
--otherwise, look both forward and backwards, then take the interval with the highest volume
cast(case
  WHEN t.date < curdate() THEN (t.allowableBlood - t.bloodPrevious)
  WHEN t.bloodPrevious < t.bloodFuture THEN (t.allowableBlood - t.bloodFuture)
  ELSE (t.allowableBlood - t.bloodPrevious)
end  as double) as allowableBlood

FROM (

SELECT
  bd.id,
  bd.dateOnly as date,
  bd.quantity,
  d.species,
  d.id.mostRecentWeight.MostRecentWeight,
  d.id.mostRecentWeight.MostRecentWeightDate,
  (d.id.mostRecentWeight.MostRecentWeight * ML_PER_KG * MAX_DRAW_PCT) as allowableBlood,
  timestampadd('SQL_TSI_DAY', (-1 * DATE_INTERVAL), bd.dateOnly) as minDate,
  timestampadd('SQL_TSI_DAY', DATE_INTERVAL, bd.dateOnly) as maxDate,
  COALESCE(
    (SELECT
      SUM(coalesce(draws.quantity, 0)) AS _expr
    FROM study."Blood Draws" draws
    WHERE draws.id = bd.id
      AND draws.date > TIMESTAMPADD('SQL_TSI_DAY', (-1 * DATE_INTERVAL), bd.dateOnly)
      AND draws.dateOnly <= bd.dateOnly
      AND (draws.qcstate.metadata.DraftData = true OR draws.qcstate.publicdata = true)
  ), 0) AS BloodPrevious,
  COALESCE(
    (SELECT
      SUM(coalesce(draws.quantity, 0)) AS _expr
    FROM study."Blood Draws" draws
    WHERE draws.id = bd.id
      AND draws.date < TIMESTAMPADD('SQL_TSI_DAY', DATE_INTERVAL, bd.dateOnly)
      AND draws.dateOnly >= bd.dateOnly
      AND (draws.qcstate.metadata.DraftData = true OR draws.qcstate.publicdata = true)
  ), 0) AS BloodFuture

FROM (
  --find the relevant blood draws, total blood drawn per day, over the relevant time window
  SELECT
    b.id,
    b.dateOnly,
    sum(b.quantity) as quantity

  FROM (
    --find all blood draws within the interval, looking backwards
    SELECT
      b.id,
      b.dateOnly,
      b.quantity,
    FROM study.blood b
    WHERE b.dateOnly >= timestampadd('SQL_TSI_DAY', -1 * DATE_INTERVAL, curdate())

    UNION ALL

    --join 1 row for the current date
    SELECT
      b.id,
      curdate() as dateOnly,
      0 as quantity,
    FROM study.blood b
    WHERE b.dateOnly >= timestampadd('SQL_TSI_DAY', -1 * DATE_INTERVAL, curdate())

    UNION ALL

    --add one row for each date when the draw drops off the record
    SELECT
      b.id,
      timestampadd('SQL_TSI_DAY', DATE_INTERVAL + 1, b.dateOnly),
      0 as quantity,
    FROM study.blood b
    WHERE b.dateOnly >= timestampadd('SQL_TSI_DAY', -1 * DATE_INTERVAL, curdate())

  ) b

  GROUP BY b.id, b.dateOnly

) bd

LEFT JOIN study.demographics d ON (d.id = bd.id)


-- 	SELECT
-- 	    CONVERT (
-- 	    	(SELECT AVG(w.weight) AS _expr
-- 	    	FROM study.weight w
-- 		    WHERE w.id=b.id AND w.date=b.lastWeighDate
-- 		    AND w.qcstate.publicdata = true
-- 		   ), double )
-- 	  ) AS weight
-- 	FROM
-- 	 	(
-- 	 		    ,( CONVERT(
--                       (SELECT MAX(w.date) as _expr
--                         FROM study.weight w
--                         WHERE w.id = bi.id
--                         --AND w.date <= bi.date
--                         AND CAST(CAST(w.date AS DATE) AS TIMESTAMP) <= bi.date
--                         AND w.qcstate.publicdata = true
--                       ), timestamp )
--                   ) AS lastWeighDate
-- 	 		    , ( COALESCE (
-- 	    			(SELECT SUM(coalesce(draws.quantity, 0)) AS _expr
-- 	    		      FROM study."Blood Draws" draws
-- 	    			  WHERE draws.id=bi.id
--                           AND draws.date >= TIMESTAMPADD('SQL_TSI_DAY', -29, bi.date)
--                           AND cast(draws.date as date) <= bi.date
--                           AND (draws.qcstate.metadata.DraftData = true OR draws.qcstate.publicdata = true)
--                           --when counting backwards, dont include this date
--                           --AND (draws.date != bi.date and draws.qcstate.label != bi.status)
--                      ), 0 )
-- 	  		      ) AS BloodLast30
-- 	 		    , ( COALESCE (
-- 	    			(SELECT SUM(coalesce(draws.quantity, 0)) AS _expr
-- 	    		      FROM study."Blood Draws" draws
-- 	    			  WHERE draws.id=bi.id
--                           AND draws.date <= TIMESTAMPADD('SQL_TSI_DAY', 29, bi.date)
--                           AND cast(draws.date as date) >= bi.date
--                           --AND draws.date BETWEEN bi.date AND TIMESTAMPADD('SQL_TSI_DAY', 29, bi.date)
--                           AND (draws.qcstate.metadata.DraftData = true OR draws.qcstate.publicdata = true)
--                           --when counting forwards, dont include this date
--                           --AND (draws.date != bi.date and draws.qcstate.label != bi.status)
--                      ), 0 )
-- 	  		      ) AS BloodNext30
--             from (
--               SELECT
--                   b.id,
--                   --b.id.dataset.demographics.species as species,
--                   cast(b.date as date) as date,
--                   --b.lsid,
--                   --b.qcstate,
--                   b.qcstate.label as status,
--                   SUM(coalesce(b.quantity, 0)) as quantity
--               FROM study.blood b
-- 	     	  WHERE cast(b.date as date) >= TIMESTAMPADD('SQL_TSI_DAY', -29, now())
-- 	     	  AND (b.qcstate.metadata.DraftData = true OR b.qcstate.publicdata = true)
-- 	     	  group by b.id, cast(b.date as date), b.qcstate.label
--
-- 	     	  UNION ALL
--               SELECT
--                   b.id,
--                   --b.id.dataset.demographics.species as species,
--                   TIMESTAMPADD('SQL_TSI_DAY', 30, cast(cast(b.date as date) as timestamp)) as date,
--                   --null as lsid,
--                   --null as qcstate,
--                   null as status,
--                   0 as quantity
--               FROM study.blood b
-- 	     	  WHERE cast(b.date as date) >= TIMESTAMPADD('SQL_TSI_DAY', -29, now())
-- 	     	  AND (b.qcstate.metadata.DraftData = true OR b.qcstate.publicdata = true)
-- 	     	  GROUP BY b.id, cast(b.date as date)
--
--               --add one row per animal, showing todays date
-- 	     	  UNION ALL
--               SELECT
--                   b.id,
--                   --b.species,
--                   curdate() as date,
--                   --null as lsid,
--                   --null as qcstate,
--                   null as status,
--                   0 as quantity
--               FROM study.demographics b
--               ) bi
-- 	    	) b
-- 	) bq

) t