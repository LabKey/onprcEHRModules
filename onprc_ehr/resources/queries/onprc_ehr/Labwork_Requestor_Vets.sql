
select a.*, b.UserId, Left(b.Email,CHARINDEX('@',b.Email)-1) as emailName from Reference_StaffNames a, onprc_ehr.usersActiveNames b
where a.username = Left(b.Email,CHARINDEX('@',b.Email)-1)
  and b.active = 'true'