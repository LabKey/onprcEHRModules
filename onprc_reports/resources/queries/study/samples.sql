/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
freezerid,
subjectid,
sampletype,
samplesubtype,
samplesource,
processdate,
concentration,
concentration_units,
quantity,
quantity_units,
comment,
dateremoved  --retain this column since downstream queries still filter on it.  more complete fix added to trunk
FROM laboratory.samples
WHERE dateremoved IS NULL