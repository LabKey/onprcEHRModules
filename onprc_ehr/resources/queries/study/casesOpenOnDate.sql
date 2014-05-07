/*
 * Copyright (c) 2014 LabKey Corporation
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
PARAMETERS(Date TIMESTAMP)

SELECT
c.Id,
c.date,
c.reviewdate,
c.enddate,
c.category,
c.allProblemCategories,
c.remark,
c.performedby

FROM study.cases c

WHERE

c.dateOnly <= Date
AND (c.enddate IS NULL OR CAST(c.enddate AS DATE) >= Date)
AND (c.reviewdate IS NULL OR CAST(c.reviewdate AS DATE) <= Date)