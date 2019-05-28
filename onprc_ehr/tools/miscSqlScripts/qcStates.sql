/*
 * Copyright (c) 2012-2017 LabKey Corporation
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

--NOTE: this script can be used to created the initial QCStates expected by the EHR study.  The containerId can be updated as needed
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Abnormal', 'Value is abnormal', TRUE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Completed', 'Record has been completed and is public', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Delete Requested', 'Records are requested to be deleted', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('In Progress', 'Draft Record, not public', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Request: Approved', 'Request has been approved', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Request: Denied', 'Request has been denied', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Request: Pending', 'Part of a request that has not been approved', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Request: Sample Delivered', 'The sample associated with this request has been delivered', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Review Required', 'Review is required prior to public release', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
INSERT INTO core.qcstate (label,description,publicdata,container) VALUES ('Scheduled', 'Record is scheduled, but not performed', FALSE, (SELECT entityid FROM core.containers WHERE name='EHR' AND parent = (SELECT entityid FROM core.containers WHERE name='ONPRC')));
