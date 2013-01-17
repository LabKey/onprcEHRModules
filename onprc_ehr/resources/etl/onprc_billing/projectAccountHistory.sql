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
        rpi.projectid as project,
        --rpi.IACUCCode as project,
		rpa.ohsuaccountnumber as account,
		rpa.aliasstartdate as startdate,
		rpa.AliasExpirationDate as enddate,
		rpa.objectid
	from Ref_ProjectsIACUC rpi join Ref_ProjectAccounts rpa on rpi.ProjectID = rpa.ProjectID

AND rpi.ts > ?

