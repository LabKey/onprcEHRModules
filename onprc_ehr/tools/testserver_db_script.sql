/*
 * Copyright (c) 2010-2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/*
This script is designed to alter DB settings on a staging/development server following a full dump from
a production server.  This script comes with no guarantee whatsoever.  Test prior to use.

Sections below can be commented/uncommented depending on your needs

*/

-- this will inactivate all users except site admins and labkey
-- update   core.Principals
-- SET      Active = FALSE
-- WHERE type = 'u'
--       AND UserId NOT IN (select p.UserId from core.Principals p inner join core.Members m on (p.UserId = m.UserId and m.GroupId=-1))
--       AND Name NOT LIKE '%@labkey.com'
--       --AND Name NOT IN ('someuser@myServer.com', 'someOtherUser@myServer.com')
-- ;

-- update the server's URL
UPDATE    prop.Properties p
SET       Value = 'http://prc-labkey3.ohsu.edu'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'SiteConfig'
          AND p.Name = 'baseServerURL'
;

-- update the server's name
UPDATE    prop.Properties p
SET       Value = 'TestServer'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'LookAndFeel'
          AND p.Name = 'systemShortName'
;

-- update the server's description
UPDATE    prop.Properties p
SET       Value = 'EHR Test Server'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'LookAndFeel'
          AND p.Name = 'systemDescription'
;

-- change a site theme
UPDATE    prop.Properties p
SET       Value = 'Seattle'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'LookAndFeel'
          AND p.Name = 'themeName'
;

-- this can be used to update the google analytics ID.
--UPDATE    prop.Properties p
--SET       Value = 'UA-XXXXXXXXX'
--WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'analytics'
--          AND p.Name = 'accountId'
--;

-- If used, update the ETL config.  This script assumes there is an existing value and uses replace so we dont save the password here
--UPDATE    prop.Properties p
--SET       Value = replace(Value, 'primatetest', 'primatedev')
--WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'onprc.ehr.etl.config'
--	      AND p.Name = 'jdbcUrl'
--;

-- turn off the ETL
UPDATE    prop.Properties p
SET       Value = 0
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'onprc.ehr.etl.config'
	      AND p.Name = 'runIntervalInMinutes'
;

-- if R or other script paths differ

--set the R program path
-- UPDATE    prop.Properties p
-- SET       Value = 'C:\\Program Files\\R\\R-2.11.1-x64\\bin\\R.exe'
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'UserPreferencesMap'
-- 	      AND p.Name = 'RReport.RExe'
-- ;
-- UPDATE    prop.Properties p
-- SET       Value = 'C:\\Program Files\\R\\R-2.11.1-x64\\bin\\R.exe'
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'ScriptEngineDefinition_R,r'
-- 	      AND p.Name = 'exePath'
-- ;


-- not used, but might be of interest
-- UPDATE    prop.Properties p
-- SET       Value = FALSE
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'SiteConfig'
--             AND p.Name = 'sslRequired'
-- ;
--
--UPDATE    prop.Properties p
--SET       Value = '8443'
--WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'SiteConfig'
--            AND p.Name = 'sslPort'
--;

-- can change the site file root
-- UPDATE    prop.Properties p
-- SET       Value = 'c:\labkey_data'
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'SiteConfig'
--             AND p.Name = 'webRoot'
-- ;

-- probably not used, but could put the site in admin mode
-- UPDATE    prop.Properties p
-- SET       Value = TRUE
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s.Set = p.Set) = 'SiteConfig'
--             AND p.Name = 'adminOnlyMode'
-- ;

-- this allows you to promote select users to site admins.  can be useful if giving a local dev a copy of the DB
-- INSERT into    core.Members m
-- (GroupId, UserId) VALUES (-1, (select userId from core.users WHERE email='yourEmail@wisc.edu')
-- ;