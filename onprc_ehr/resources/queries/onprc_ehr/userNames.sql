SELECT
  u.DisplayName,
  'u' as type,
  u.FirstName,
  u.LastName,
  u.Active

FROM onprc_ehr.usersActiveNames u