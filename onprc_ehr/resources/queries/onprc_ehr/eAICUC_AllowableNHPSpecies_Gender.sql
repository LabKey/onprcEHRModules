/*' updated 2022-07-25 */
SELECT
g.Parent_Protocol,
g.Species,
g.gender,
Sum(g.Number_of_Animals_Max) TotalAllowableNHPs
FROM eIACUC_PRIME_VIEW_ANIMAL_GROUPS g
where g.species not in ('rat','Guinea Pig','rabbit','mouse')
Group By
g.Parent_Protocol,
g.Species,
g.gender