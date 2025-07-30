-- Created: 7-29-2025  R.Blasa

select value,
       category

from ehr_lookups.pairingstarttype
Where date_disabled is null

union

select value,
       category

from ehr_lookups.pairingendtypes
Where date_disabled is null