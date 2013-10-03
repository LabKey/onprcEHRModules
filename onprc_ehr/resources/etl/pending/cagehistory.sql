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
select
  t.Cageid,
  t.Location,
  t.Row,
  t.Cage,
  t.CagetypeID,
  t.DividerType,
  t.maxDifferent,
  t.datestarted,
  CASE
  WHEN maxDifferent IS NULL THEN (select min(datestarted) from Ref_RowCageHistory r2 WHERE r2.DateStarted < t.DateStarted and r2.Cageid = t.Cageid and r2.CagetypeID = t.CagetypeID and r2.DividerType = t.DividerType and r2.DateStarted >= '2012-12-31')
  ELSE maxDifferent
  END as StartDate
--max(t.datestarted) as datestarted

from (

       select
         r.Cageid,
         l.Location,
         rc.Row,
         rc.Cage,
         r.CageTypeId,
         r.dividertype,
         r.datestarted,
--find the last date this cage did not have this configuration
         (select max(datestarted) from Ref_RowCageHistory r2 WHERE r2.DateStarted < r.DateStarted and r2.Cageid = r.Cageid and r2.CagetypeID != r.CagetypeID and r2.DividerType != r.DividerType and r2.DateStarted >= '2012-12-31') as maxDifferent

       from Ref_RowCageHistory r
         left join Ref_RowCage rc on (r.Cageid = rc.CageID)
         left join Ref_Location l on (rc.LocationID = l.LocationId)
       where r.DateStarted > '2013-01-01'

     ) t

--group by Cageid, CagetypeID, DividerType, coalesce(t.startdate, t.datestarted)

order by Location, row, Cage, DateStarted desc


