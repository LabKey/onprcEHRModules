select a.Id,
       a.date,
       b.Id.curLocation.area,
       b.Id.curLocation.room,
       b.Id.curLocation.cage,
       a.label,
       a.comment,
       b.calculated_status as LiveStatus

from genotypesWithSignificance a, study.demographics b where a.Id = b.Id