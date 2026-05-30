/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

ALTER TABLE extscheduler.Resources Add Room VARCHAR(255);
ALTER TABLE extscheduler.Resources Add Bldg VARCHAR (255);


ALTER TABLE extscheduler.Events ADD  Alias VARCHAR(25);