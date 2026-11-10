
PARAMETERS(GroupName VARCHAR)
SELECT *
FROM core.Users u
WHERE u.UserId in (
   SELECT m.UserId
   FROM core.Members m
   WHERE m.GroupId.Name = GroupName
)