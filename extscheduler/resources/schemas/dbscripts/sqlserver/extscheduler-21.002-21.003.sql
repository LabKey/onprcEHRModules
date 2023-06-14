-- Created: 6-13-2023  R. Blasa

ALTER TABLE extscheduler.Events ADD  fasting VARCHAR(500);
GO

ALTER TABLE extscheduler.Events ADD  delivery VARCHAR(500);
GO

ALTER TABLE extscheduler.Events ADD  project INT;
GO

ALTER TABLE extscheduler.Events ADD  remainingtissues VARCHAR(50);
GO

ALTER TABLE extscheduler.Events ADD  animalid VARCHAR(50);
GO