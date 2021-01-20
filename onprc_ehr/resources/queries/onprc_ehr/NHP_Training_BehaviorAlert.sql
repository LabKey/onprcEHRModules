SELECT
    Id,
    date,
    training_Ending_Date,
    training_type,
    reason,
    training_results,
    remark,
    taskid,
    performedby
FROM NHP_Training
Where training_results = 'In-Progress'
And TIMESTAMPDIFF(day, date, now()) > 60
