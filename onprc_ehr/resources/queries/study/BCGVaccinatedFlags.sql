/* Created by Kollil, 9/6/23
  Get the new animals found with the flag, "NHPR NOTE: BCG Vaccinated".
*/
Select
    f.Id,
    f.Date,
    f.enddate,
    f.flag.category as category,
    f.flag.value as meaning,
    f.remark
From study.flags f, ehr_lookups.flag_categories fc
Where f.flag.category = fc.category
  And f.isActive = true
  And f.flag.category like 'NHPR Note'
  And f.flag.value like 'BCG Vaccinated'
--And date = timestampadd(SQL_TSI_DAY, -1, CAST(CURDATE() AS date))