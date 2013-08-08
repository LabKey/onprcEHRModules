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

CREATE SCHEMA genotypeassays;

CREATE TABLE genotypeassays.assaytypes (
  name varchar(100),
  description varchar(4000),

  CONSTRAINT pk_assaytypes PRIMARY KEY (name)
);

INSERT INTO genotypeassays.assaytypes (name, description) VALUES ('SSP', 'Sequence-specific PCR');
INSERT INTO genotypeassays.assaytypes (name, description) VALUES ('STR', 'Microsatellite');
INSERT INTO genotypeassays.assaytypes (name, description) VALUES ('SBT', 'Sequence-based Genotyping');