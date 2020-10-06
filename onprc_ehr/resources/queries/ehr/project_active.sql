SELECT project.name,
project.protocol,
project.investigatorId,
project.title,
project.use_category,
project.startdate,
project.enddate,
project.shortname,
project.container,
project.displayName,
project.account
FROM project
where (enddate is null or enddate >= Now())