/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
select
  t.AnimalId,
  t.date,
  case
  when t.timeString is null or t.timeString = '' or LEN(t.timeString) = 0 then t.date
  when LEN(t.timeString) = 3 then convert(datetime, CONVERT(varchar(100), t.timeString, 111) + ' 0' + left(t.timeString, 1) + ':' + RIGHT(t.timeString, 2))
  else convert(datetime, CONVERT(varchar(100), t.date, 111) + ' ' + left(t.timeString, 2) + ':' + RIGHT(t.timeString, 2))
  end as date,

  t.parentid,
  t.runid,
  t.result,
  t.qualResult,
  t.testid,
  t.objectid

from (

select
     t0.AnimalID,
     t0.Date,
     ltrim(rtrim(replace(t0.time, '_', '0'))) as timeString,
     t0.objectid,
     t0.parentid,
     t0.qualResult,
     t0.result,
     t0.runid,
     t0.testid
 from (

select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.DiastolicBP as result,
    null as qualResult,
    'DiastolicBP' as testid,
    cast(l.objectid as varchar(36)) + 'DiastolicBP' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.DiastolicBP is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.EtCO2 as result,
    null as qualResult,
    'EtCO2' as testid,
    cast(l.objectid as varchar(36)) + 'EtCO2' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.EtCO2 is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.HeartRate as result,
    null as qualResult,
    'HeartRate' as testid,
    cast(l.objectid as varchar(36)) + 'HeartRate' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.HeartRate is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.IBPMap as result,
    null as qualResult,
    'IBPMap' as testid,
    cast(l.objectid as varchar(36)) + 'IBPMap' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.IBPMap is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    null as result,
    l.IBPSD as qualResult,
    'IBPSD' as testid,
    cast(l.objectid as varchar(36)) + 'IBPSD' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.IBPSD is not null and l.IBPSD != '')

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.N2OFlow as result,
    null as qualResult,
    'N2OFlow' as testid,
    cast(l.objectid as varchar(36)) + 'N2OFlow' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.N2OFlow is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.NIBPMap as result,
    null as qualResult,
    'NIBPMap' as testid,
    cast(l.objectid as varchar(36)) + 'NIBPMap' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.NIBPMap is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.O2Flow as result,
    null as qualResult,
    'O2Flow' as testid,
    cast(l.objectid as varchar(36)) + 'O2Flow' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.O2Flow is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.RespirationRate as result,
    null as qualResult,
    'RespirationRate' as testid,
    cast(l.objectid as varchar(36)) + 'RespirationRate' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.RespirationRate is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.SpO2 as result,
    null as qualResult,
    'SpO2' as testid,
    cast(l.objectid as varchar(36)) + 'SpO2' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.SpO2 is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.SystolicBP as result,
    null as qualResult,
    'SystolicBP' as testid,
    cast(l.objectid as varchar(36)) + 'SystolicBP' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.SystolicBP is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.Temperature as result,
    null as qualResult,
    'Temperature' as testid,
    cast(l.objectid as varchar(36)) + 'Temperature' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.Temperature is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.Vaporizer as result,
    null as qualResult,
    'Vaporizer' as testid,
    cast(l.objectid as varchar(36)) + 'Vaporizer' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.Vaporizer is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.pCO2 as result,
    null as qualResult,
    'pCO2' as testid,
    cast(l.objectid as varchar(36)) + 'pCO2' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.pCO2 is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.pH as result,
    null as qualResult,
    'pH' as testid,
    cast(l.objectid as varchar(36)) + 'pH' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.pH is not null)

  UNION ALL

  select
    g.AnimalID,
    g.Date,
    l.Time,
    g.objectid as parentid,
    h.objectid as runid,

    l.pO2 as result,
    null as qualResult,
    'pO2' as testid,
    cast(l.objectid as varchar(36)) + 'pO2' as objectid,
    l.ts

  from Sur_AnesthesiaLogData l
    left join Sur_General g on (l.SurgeryID = g.SurgeryID)
    left join Sur_AnesthesiaLogHeader h on (h.SurgeryID = g.SurgeryID)
  WHERE (l.pO2 is not null)

) t0

where t0.ts > ?

) t