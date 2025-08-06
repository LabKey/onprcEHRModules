SELECT

    h1.Id,
    group_concat(h2.Id) as infantcagemate,
    group_Concat(distinct h2.room) as room,
    group_concat(distinct h1.cage) as cage

FROM study.demographicsCurrentLocation h1
         JOIN study.demographicsCurrentLocation h2 ON (
    h1.room = h2.room AND
    h1.cage = h2.cage

    )

WHERE
    h1.room.housingType.value = 'Cage Location' AND
    h2.Id.age.ageInyears < 1

GROUP BY h1.Id