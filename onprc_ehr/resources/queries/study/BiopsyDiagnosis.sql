Select
    a.participantid as Id,
    a.date,
    a.tissue.meaning as "Organ/Tissue",
    a.remark as Diagnosis,
    a.codes as "Snomed Codes",
    a.taskid

From study.histology a, ehr.tasks b
Where a.taskid = b.taskid
  And b.formtype = 'Biopsy'