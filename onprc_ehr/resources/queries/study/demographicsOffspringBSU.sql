/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d.id,
d.gender.meaning as gender,
'Offspring' as Relationship,

d2.id  AS Offspring,
d2.birth,
d2.birthType,
d2.offspringgender,
d2.status,
d2.geneticdam,
d2.observeddam,
d2.fosterMom,
d2.sire,
d2.sireType,
d.qcstate

FROM study.Demographics d

INNER JOIN study.demographicsParentsBSU d2

  ON ((d2.sire = d.id OR d2.geneticdam = d.id  OR d2.fostermom = d.id OR d2.observeddam = d.id) AND d.id != d2.id)



