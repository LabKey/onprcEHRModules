-- select
--      value,
--      category,
--      sort_order,
--      date_disabled
--
-- from ehr_lookups.pairingdividerchange
--
-- union all

select
    value,
    category,
    sort_order,
    date_disabled

from ehr_lookups.pairingEventType

union all

select
    value,
    category,
    sort_order,
    date_disabled

from ehr_lookups.pairing_infant_related

union all

select
    value,
    category,
    sort_order,
    date_disabled

from ehr_lookups.pairing_STF_Beh

union all

select
    value,
    category,
    sort_order,
    date_disabled

from ehr_lookups.pairing_STF_clinical

order by category, value, sort_order