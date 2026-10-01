/*
 * Drop the 2020 Covid-19 scheduling scaffolding. The dateParts window these procedures read is frozen at
 * 2020-05-01 through 2021-04-20, so they can only ever generate events dated 2020-2021. extBlockOutEvening
 * additionally violates CHK_event_DateRangeValid -- its StartDate is date + 1530 hours, a 15:30 clock time
 * misread as an hour count -- and has never inserted a row.
 */

EXEC core.fn_dropifexists 'extBlockOutEvening', 'extscheduler', 'PROCEDURE';
GO

EXEC core.fn_dropifexists 'extBlockOutMorning', 'extscheduler', 'PROCEDURE';
GO

EXEC core.fn_dropifexists 'extBlockOutDays', 'extscheduler', 'PROCEDURE';
GO

EXEC core.fn_dropifexists 'dateParts', 'extscheduler', 'TABLE';
GO
