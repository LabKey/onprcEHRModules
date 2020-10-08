/*
Created:  2020-05-07
Created by jonesga
Purpose:  Update of Comments field of scheduler per user request

*/
ALTER TABLE extscheduler.Events ALTER COLUMN  Comments NVARCHAR(4000);