-- Extract the Animals with no Tattoos
SELECT
    d.id,
    d.birth,
    d.gender,
    d.id.curLocation.room + ' ' +  d.id.curLocation.cage as location,
FROM study.demographics d
WHERE
    d.calculated_status = 'Alive'
    And d.Id not in
    (Select e.id from study.encounters e Where d.id = e.id And e.procedureid = 760) --Tattoo

