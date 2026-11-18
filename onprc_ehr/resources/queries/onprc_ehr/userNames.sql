/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  u.DisplayName,
  'u' as type,
  u.FirstName,
  u.LastName,
  u.Active

FROM onprc_ehr.usersActiveNames u