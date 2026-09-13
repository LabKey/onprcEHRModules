/*
 * Drop the 2020 Covid-19 scheduling scaffolding. The dateParts window these procedures read is frozen at
 * 2020-05-01 through 2021-04-20, so they can only ever generate events dated 2020-2021. extBlockOutEvening
 * additionally violates CHK_event_DateRangeValid -- its StartDate is date + 1530 hours, a 15:30 clock time
 * misread as an hour count -- and has never inserted a row.
 */

-- Note: The bootstrap script doesn't create these procedures or the table. This clean up is here for only a few
-- development machines that ran a previous version of the bootstrap script. When consolidation takes place, these
-- statements can simply be removed.

DROP PROCEDURE IF EXISTS extscheduler."extBlockOutEvening";
DROP PROCEDURE IF EXISTS extscheduler."extBlockOutMorning";
DROP PROCEDURE IF EXISTS extscheduler."extBlockOutDays";
DROP TABLE IF EXISTS extscheduler."dateParts";
