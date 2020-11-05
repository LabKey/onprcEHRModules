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