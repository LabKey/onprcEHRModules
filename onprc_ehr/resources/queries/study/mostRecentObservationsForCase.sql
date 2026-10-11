/*
 * Copyright (c) 2014-2026 LabKey Corporation
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
WITH LatestObservationDates AS (
    SELECT
        Id,
        caseid,
        MAX(date) AS latest_date
    FROM study.clinical_observations
    WHERE caseid IS NOT NULL
      AND category NOT IN ('Vet Review', 'Reviewed')
    GROUP BY Id, caseid
),
     FilteredObservations AS (
         SELECT
             o.Id,
             o.caseid,
             o.date,
             CASE WHEN o.category <> 'Observations' THEN o.category END AS category,
             NULLIF(o.area, 'N/A') AS area,
             o.observation,
             COALESCE(
                     CASE WHEN o.remark IS NOT NULL AND o.observation IS NOT NULL
                              THEN ('.  ' || o.remark )
                          ELSE o.remark
                         END,
                     ''
             ) AS remark
         FROM study.clinical_observations o
         WHERE o.caseid IS NOT NULL
           AND o.category NOT IN ('Vet Review', 'Reviewed')
     ),
     ObservationStrings AS (
         SELECT
             fo.Id,
             fo.caseid,
             fo.date,
             CASE
                 WHEN fo.category IS NULL AND fo.observation IS NOT NULL
                     THEN (fo.observation ||  '. ' || fo.remark)
                 WHEN fo.category IS NOT NULL AND fo.observation IS NULL
                     THEN (fo.category || fo.remark)
                 WHEN fo.category IS NOT NULL AND fo.area IS NULL
                     THEN (fo.category || ': ' || fo.observation || fo.remark)
                 WHEN fo.category IS NOT NULL AND fo.area IS NOT NULL
                     THEN (fo.category || ': ' || fo.area || ', ' || fo.observation)
                 ELSE fo.remark
                 END AS observation_string
         FROM FilteredObservations fo
                  INNER JOIN LatestObservationDates lod
                             ON fo.Id = lod.Id
                                 AND fo.caseid = lod.caseid
                                 AND fo.date = lod.latest_date
     )
SELECT
    Id,
    caseid,
    MAX(date) AS latest_date,
    GROUP_CONCAT(
            CAST(observation_string AS VARCHAR(1000)),
            CHAR(10)
    ) AS observations
FROM ObservationStrings
GROUP BY Id, caseid