select k.Id,K.date,k.room,k.cage,s.room as "Housing Room",s.cage as "Housing Cage"

from study.birth k, study.Housing s
where ((s.reason = 'initialTransfer' or s.reason is null) and s.reason <> 'unknown')
and (s.room.room <> k.room.room and (s.cage <> k.cage or s.cage is null and k.cage is null))
and (k.Id = s.participantid)
and k.qcstate.publicdata = true

