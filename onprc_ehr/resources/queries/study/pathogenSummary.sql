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
PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  t1.pathogen,
  t1.category,
  max(t1.totalTests) as totalTests,
  max(t1.totalIds) as totalIds,
  sum(t1.positive) as totalPositive,
  count(distinct t1.IdPositive) as distinctPositive,
  max(t1.totalTests) - sum(t1.positive) as totalNegative,
  max(t1.totalIds) - count(distinct t1.IdPositive) as distinctNegative,
  count(distinct t1.wasSPFId) as numInitiallySPF,
  count(distinct t1.neverSPFId) as numNeverSPF,
  count(distinct t1.endedSPFId) as numEndedSPF,
  count(distinct t1.leftCenterId) as numLeftCenter,
  count(distinct t1.droppedFromSPFId) as numDroppedFromSPF,

  max(t1.StartDate) as StartDate,
  max(t1.EndDate) as EndDate,

FROM study.pathogenData t1
WHERE t1.pathogen != 'ETIOLOGIC AGENT NOT IDENTIFIED,(NEGATIVE)'
GROUP BY t1.pathogen, t1.category