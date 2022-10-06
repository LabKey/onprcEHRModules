--query to update the protocol id in projects table to match external ID of protocols
Update ehr.project
	set protocol = e.external_id

  FROM [ehr].[project] p, ehr.protocol e
  where p.protocol = e.protocol and (p.enddate > getDate() or p.enddate is null)