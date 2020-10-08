/*
Created:  2020-05-07
Created by jonesga
Purpose:  To provide a resource for insert of dates into Scheduling tool

*/
CREATE TABLE extScheduler.Covid19Calendar(cDate datetime, cDay int, cDayOfWeek int, cDayName varchar(20), cMonth int);

DECLARE @date date = '20200501';
WHILE @date <= '20210430'
    BEGIN
        INSERT INTO Calendar VALUES (@date,
                                     DAY(@date),
                                     DATEPART(weekday, @date),
                                     DATENAME(weekday, @date),
                                     MONTH (@date));
        SET @date = DATEADD(day, 1, @date);
    END