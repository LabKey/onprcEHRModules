/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d1.id,

d1.id.parents.dam as dam,

d1.id.parents.sire as sire,

dam.id.parents.dam AS MaternalGranddam,

dam.id.parents.sire AS MaternalGrandsire,

sire.id.parents.dam AS PaternalGranddam,

sire.id.parents.sire AS PaternalGrandsire,

d1.qcstate

FROM study.Demographics d1

LEFT JOIN study.Demographics dam
  ON (d1.id.parents.dam = dam.id)

LEFT JOIN study.Demographics sire
  ON (d1.id.parents.sire = sire.id)
