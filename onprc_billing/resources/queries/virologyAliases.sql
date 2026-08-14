SELECT rowid,aliases.alias, aliases.alias + ' - ' + aliases.investigatorName as aliasPI
FROM aliases
WHERE projectStatus = 'Active'