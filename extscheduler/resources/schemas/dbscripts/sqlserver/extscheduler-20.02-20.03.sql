/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/*
Created:  2020-05-07
Created by jonesga
Purpose:  Update of Comments field of scheduler per user request

*/
ALTER TABLE extscheduler.Events ALTER COLUMN  Comments NVARCHAR(4000);