SELECT
a.Parent_Protocol,
a.Species,
Sum(a.Number_of_Animals_Max)
FROM eIACUC_PRIME_VIEW_ANIMAL_GROUPS a
group by
a.Parent_Protocol,
a.Species