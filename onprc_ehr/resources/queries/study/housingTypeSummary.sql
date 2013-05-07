SELECT

h.room.housingType.value as housingType,
count(distinct h.id) as totalAnimals

FROM study.housing h
WHERE h.enddateTimeCoalesced >= now()

GROUP BY h.room.housingType.value