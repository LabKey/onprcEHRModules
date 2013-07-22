select
  'Legacy data' as comment,
  ri.RunDate as runDate,
  ri.StartDate as billingPeriodStart,
  ri.EndDate as billingPeriodEnd,
  ri.objectid as objectid
from IRIS_Production.dbo.Ref_Invoice ri
where ri.ts > ?