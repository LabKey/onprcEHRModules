SELECT
  field as set_name,
  value,
  displayorder as sort_order,
  datedisabled,
  objectid

FROM sys_parameters s

WHERE ts > ?