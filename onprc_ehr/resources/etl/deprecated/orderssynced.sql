select
Accession_Number as order_accession,
Recorded_Date merge_datecreated,
Posted_Date merge_dateposted,
objectid,
1 as resultsreceived

from IRIS_Lis_TransactionlogMaster
WHERE ts > ?