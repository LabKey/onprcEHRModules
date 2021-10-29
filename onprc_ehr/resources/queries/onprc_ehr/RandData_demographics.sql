SELECT --s.id,
--s.Rh,
d.Id,
d.gender,
d.species,
d.geographic_origin,
d.birth,
d.death,
d.calculated_status,

d.taskid,
d.performedby,
d.requestid,
d.Container,
d.lastDayAtCenter,
d.history,
d.lastVetReview,
s.Cohort,
s.PI,
s.Cohort_id,
s.subcohort,
s.grp

FROM StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.demographics d
where (active = 'y' and s.rh = d.id)