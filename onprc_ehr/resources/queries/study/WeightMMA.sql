-- Created by Kolli, March 2026
--New query created in the code base as the automated tests are failing.
SELECT s.Id,
       s.date,
       s.set_number,
       s.code,
       s.qualifier
FROM ehr.snomed_tags s
where s.code like 'P-YY961'

Union

SELECT s.Id,
       s.date,
       s.set_number,
       s.code,
       s.qualifier
FROM ehr.snomed_tags s
where s.code like 'P-YY960'