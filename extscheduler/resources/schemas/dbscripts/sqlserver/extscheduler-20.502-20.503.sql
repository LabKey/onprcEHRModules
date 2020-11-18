/*
Created:  2020-05-07
Created by jonesga
Purpose:  Dataset to mimic DateRange from Labkey for SCheduler actionin SQL

*/
EXEC core.fn_dropifexists 'DateParts','extScheduler','TABLE';
GO

CREATE TABLE extScheduler.dateParts
(date datetime,
dateOnly datetime,
DayOfYear int,
DayofMonth int,
DayofWeek int,
DayName varchar(20),

WeekofMonth int,
WeekofYear int,
 Month int,
 year int)

Go

Insert into  extScheduler.DateParts
    (Date,
    dateonly,
    DayOfYear,
    DayofMonth,
    DayofWeek,
    DayName,
    WeekofMonth,
    WeekofYear,
    Month,
    year)
Select

    i.NDate,
    CAST(i.Ndate as date) as dateOnly,
    cast(datepart(dy,i.Ndate) as integer) as DayOfYear,
    cast(datepart(dd,i.Ndate) as integer) as DayOfMonth,
    cast(datepart(dw,i.Ndate) as integer) as DayOfWeek,
    cast(dateName(dd,i.Ndate) as VarChar(20)) as DayName,
    (cast(datepart(dd,i.Ndate) as integer)/ 7) as WeekofMonth,
    cast(datepart(wk,i.Ndate) as integer) as WeekofYear,
    cast(datepart(mm,i.Ndate) as integer) as Month,
    cast(datepart(yyyy,i.Ndate) as integer) as Year
FROM (SELECT DateAdd(dd, i.value, '5/1/2020') as NDate FROM ldk.integers i)i
Where i.nDate <= '4/20/2021'