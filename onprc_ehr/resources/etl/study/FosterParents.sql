/*
 * Copyright (c) 2012 LabKey Corporation
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
/*
Birth_FosterMom

Created by: Lakshmi Kolli	Date: 8/7/2012

Tested by: 			Date:
       Raymond Blasa                8/23/2012

*/
SELECT
	--Searchkey as SearchKey,
	cast(Infant_ID as nvarchar(4000)) as Id,
	cast(Foster_Mom as nvarchar(4000)) as Dam,
	Foster_Start_Date as date,
	Foster_End_Date as enddate,
	objectid
--	ts as ts,

From Birth_FosterMom

WHERE ts > ?
