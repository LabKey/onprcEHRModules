SELECT
  t.project,
  cast(t.project.title as varchar(200)) as title,
  ' [By Invoice]' as summaryByInvoice,
  ' [All Items]' as allItems

FROM publicInvoicedItems t
WHERE t.project is not null
GROUP BY t.project, t.project.title