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
--creates a table in the legacy IRIS system used to house records of deletes in those tables
DROP table deleted_records;
CREATE TABLE deleted_records (
	id varchar(255) DEFAULT NULL,
	objectid varchar(255) DEFAULT NULL,
	ts varbinary,
	tableName varchar(255) DEFAULT NULL,
	created timestamp
);