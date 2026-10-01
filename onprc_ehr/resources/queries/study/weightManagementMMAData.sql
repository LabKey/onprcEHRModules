/*
 Created by Kollil
 Animals that were in the weight management regimen. Data showing both weight BEGIN and RELEASE snomed codes
 */
SELECT s.Id,
       s.date,
       s.set_number,
       s.code,
       s.qualifier
FROM ehr.snomed_tags s
where s.code like 'P-YY961' -- Begin active weight management regimen

Union

SELECT s.Id,
       s.date,
       s.set_number,
       s.code,
       s.qualifier
FROM ehr.snomed_tags s
where s.code like 'P-YY960' -- Release from active weight management regimen