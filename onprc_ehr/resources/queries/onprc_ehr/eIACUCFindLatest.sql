select p.rowID,
       p.BaseProtocol,
       p.RevisionNumber,
       p.Protocol_State,
       p.Protocol_Id,
       p.Last_Modified,
from eiACUC2Data2 p
where p.last_Modified = (Select Max(p1.Last_Modified) from eIACUC2Data2 p1 where p1.BaseProtocol = p.BaseProtocol)
order by p.BaseProtocol