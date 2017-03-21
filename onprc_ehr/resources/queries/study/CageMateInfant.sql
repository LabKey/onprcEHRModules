

select

a.id,
a.room,
e.offspringUnder1Yr as InfantCageMate,
a.QCState

 from study.housingRoommates a, study.demographicsInfantUnderOne e
where  a.RoommateId.Id = e.offspringUnder1Yr
And a.Id.DataSet.demographics.calculated_status.code = 'Alive'
And e.Id.DataSet.demographics.calculated_status.code = 'Alive'
and a.roommateEnd  is null
and a.qcstate = 18
and a.room.housingtype.value = 'Cage Location'