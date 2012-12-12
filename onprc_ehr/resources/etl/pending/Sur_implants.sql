select
  v.AnimalID,
  v.date,
  v.SequenceNo,
  v.implantcount,
  v.size as sizeInt,
  s1.Value as size,
  v.type as typeInt,
  s2.Value as type,
  v.site as siteInt,
  s3.Value as site,
  v.action as actionInt,
  s4.Value as action,
  v.chargecode as charcodeCodeInt,
  s5.Value as chargeCode,
  v.surgeon,
  v.comments,
  v.objectid  
  
from Sur_Implants v
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'ImplantSize' AND s1.Flag = v.size)
LEFT JOIN Sys_parameters s2 ON (s2.Field = 'ImplantType' AND s2.Flag = v.type) 
LEFT JOIN Sys_parameters s3 ON (s3.Field = 'ImplantSite' AND s3.Flag = v.site)
LEFT JOIN Sys_parameters s4 ON (s4.Field = 'ImplantAction' AND s4.Flag = v.action)
LEFT JOIN Sys_parameters s5 ON (s5.Field = 'SurgeryChargeCode' AND s5.Flag = v.chargecode)

  