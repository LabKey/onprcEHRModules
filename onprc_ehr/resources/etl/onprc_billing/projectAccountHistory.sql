/*
 * Copyright (c) 2013-2014 LabKey Corporation
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

SELECT * FROM (
select
    rpa.projectid as project,
		ltrim(rtrim(rpa.ohsuaccountnumber)) as account,
		CASE
			WHEN (rpa.aliasstartdate >= rpa.DateCreated) THEN CAST(rpa.aliasstartdate AS DATE)
			ELSE CAST(rpa.DateCreated  AS DATE)
		END as startdate,
		COALESCE(CASE
			WHEN (rpa.AliasExpirationDate >= rpa.DateDisabled) THEN CAST(dateadd(d, -1, rpa.DateDisabled) AS DATE)
			ELSE CAST(Dateadd(d, -1,rpa.AliasExpirationDate) AS DATE)
		END, CAST('2015/04/30' as date)) as enddate,
		rpa.objectid
	from Ref_ProjectAccounts rpa
  where rpa.ts > ?
) t WHERE t.startdate >= '2009-01-01' and ltrim(rtrim(t.account)) IS NOT NULL and ltrim(rtrim(t.account)) != ''