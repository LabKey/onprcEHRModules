SELECT b.Id,
b.date,
b.date_type,
b.birth_condition,
b.room,
b.cage,
b.dam

FROM birth b join study.flags s on b.dam = s.id and s.flag.value = 'JMac Obese HFD' and s.enddate is null