-- Created: 6-20-2018  R.Blasa

select value, sort_order from sla.Reference_Data
where columnName = 'PairingStarttype'
And endDate is null