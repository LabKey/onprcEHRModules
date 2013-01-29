select rowid, set_name, value, sort_order
from ehr_lookups.lookups l
where l.set_name = 'LocationDefinition' AND date_disabled IS NULL