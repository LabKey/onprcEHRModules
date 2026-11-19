/*
 Created by Kollil
 Animals started weight management regimen MMA, but not released
  */
SELECT w.Id,
       Max(w.date) as CurrentCode,
       w.code
FROM study.weightManagementMMAData w
where w.code = 'P-YY961'
group by w.id,w.code