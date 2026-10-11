/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
ALTER TABLE geneticscore.mhc_data ADD objectid ENTITYID;
ALTER TABLE geneticscore.mhc_data ADD totalTests int;