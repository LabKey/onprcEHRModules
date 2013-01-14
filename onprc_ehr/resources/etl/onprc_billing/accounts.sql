SELECT
p.ohsuaccountnumber as account,

count(*) as total

FROM Ref_ProjectAccounts p

WHERE p.datedisabled is null and datalength(p.OHSUAccountNumber) > 0 
and p.OHSUAccountNumber != ' '
and p.OHSUAccountNumber != '0'
and p.OHSUAccountNumber != '00000000000'
and p.OHSUAccountNumber NOT LIKE '111%'

group by p.ohsuaccountnumber

having MAX(ts) > ?