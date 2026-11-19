/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Select
Id,
meanKinship,
zscore,
genomeUniqueness,
totalOffspring,
livingOffspring,
assignments as TotalAssignments,
condition,
value as GeneticValue,
rank
From Site.{substitutePath moduleProperty('ONPRC_EHR','DCM_NHP_Resources_Container')}.lists.GeneticValue