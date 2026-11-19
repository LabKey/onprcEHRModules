/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT c.id,
c.species,
c.gender,
c.DaysAge,
c.Weight,
c.MostRecentWeightDate,
c.date as BCSDate,
c.bcs as BCSScore,
c.CalcMethod,
c.bpk,
c.interval,
c.Percentage,
c.CalcMethodReason,
(c.bpk*c.Weight) as TOtalBloodVolume

FROM bloodCalcCriteria c
WHere c.CalcMethod = 'FR'