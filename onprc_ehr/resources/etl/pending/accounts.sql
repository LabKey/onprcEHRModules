/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
SELECT
p.ohsuaccountnumber as account,
MAX(CONVERT(varchar(38), p.objectid)) as objectid,

count(*) as total

FROM Ref_ProjectAccounts p

WHERE p.datedisabled is null and datalength(p.OHSUAccountNumber) > 0 
and p.OHSUAccountNumber != ' '
and p.OHSUAccountNumber != '0'
and p.OHSUAccountNumber != '00000000000'
and p.OHSUAccountNumber NOT LIKE '111%'

group by p.ohsuaccountnumber

having MAX(ts) > ?