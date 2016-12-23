select a.project as project,
a.name as centerproject,
b.external_id as Protocol,
g.lastname as investigator,
  ( a.name + '-' + ' [' + g.LastName + ' - ' + b.external_id + ']' ) as projectname ,
   ( b.external_id + '-' + ' [' + g.LastName + ' - ' + a.name + ']' ) as protocolname ,
  a.enddate as enddate

 from  ehr.project a
left join  ehr.protocol b on(rtrim(a.protocol)= rtrim(b.protocol))
 left join  onprc_ehr.investigators g on (g.rowId = a.investigatorId)
where ( a.enddate is null or a.enddate >= Now())


order by centerproject
