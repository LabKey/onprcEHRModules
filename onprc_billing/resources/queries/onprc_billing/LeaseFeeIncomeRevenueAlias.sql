Select
i.rowID,
i.project,
i.startDate,
i.enddate,
i.comment,
p.account
from projectLeaseIncomeEligibility i
    left join projectAccountHistory p on i.project = p.project