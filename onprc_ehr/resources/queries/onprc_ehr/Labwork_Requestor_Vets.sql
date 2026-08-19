
select a.*, b.UserId, Left(b.Email,LOCATE('@',b.Email)-1) as emailName from Reference_StaffNames a, onprc_ehr.usersActiveNames b
where a.username = Left(b.Email,LOCATE('@',b.Email)-1)
  and b.active = 'true'