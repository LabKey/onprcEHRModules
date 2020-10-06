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
 *  Updated 2019-01-26
 *  revied to allow assigned of vet by Protocol and Room or Protocol and Area
 */
SELECT
  v.userId,

  group_concat(DISTINCT ( CASE WHEN (v.protocol is not null and v.room is not null)  THEN (v.protocol.displayname || '-' || v.room) ELSE '' END), chr(10)) as Protocol_Room,
  group_concat(DISTINCT ( CASE WHEN (v.protocol is not null and v.area is not null)  THEN (v.protocol.displayname || '-' || v.area) ELSE '' END), chr(10)) as Protocol_Area,
  group_concat(DISTINCT (v.protocol.displayName || ' (' || v.protocol.investigatorid.lastname || ')'), chr(10)) as protocols,
  group_concat(DISTINCT (v.room || CASE WHEN v.priority = true THEN '*' ELSE '' END), chr(10)) as rooms,
  group_concat(DISTINCT (v.area || CASE WHEN v.priority = true THEN '*' ELSE '' END), chr(10)) as areas



FROM onprc_ehr.vet_assignment v
GROUP BY v.userId