/*
 * Copyright (c) 2012-2017 LabKey Corporation
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
UPDATE    prop.Properties
SET       Value = 'https://prime-test.ohsu.edu'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'SiteConfig'
          AND Name = 'baseServerURL'
;

-- update the server's name
UPDATE    prop.Properties
SET       Value = 'TestServer'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'LookAndFeel'
          AND Name = 'systemShortName'
;

-- update the server's description
UPDATE    prop.Properties
SET       Value = 'EHR Test Server'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'LookAndFeel'
          AND Name = 'systemDescription'
;

-- change a site theme
UPDATE    prop.Properties
SET       Value = 'Seattle'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'LookAndFeel'
          AND Name = 'themeName'
;

-- this can be used to update the google analytics ID.
--UPDATE    prop.Properties
--SET       Value = 'UA-XXXXXXXXX'
--WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'analytics'
--          AND Name = 'accountId'
--;

--disable google analytics
UPDATE    prop.Properties
SET       Value = 'disabled'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'analytics'
          AND Name = 'trackingStatus'
;


-- If used, update the ETL config.  This script assumes there is an existing value and uses replace so we dont save the password here
--UPDATE    prop.Properties
--SET       Value = replace(Value, 'primatetest', 'primatedev')
--WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'onprc.ehr.org.labkey.onprc_ehr.etl.config'
--	      AND Name = 'jdbcUrl'
--;

-- if R or other script paths differ

--set the R program path
-- UPDATE    prop.Properties
-- SET       Value = 'C:\\Program Files\\R\\R-2.11.1-x64\\bin\\R.exe'
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'UserPreferencesMap'
-- 	      AND Name = 'RReport.RExe'
-- ;
-- UPDATE    prop.Properties
-- SET       Value = 'C:\\Program Files\\R\\R-2.11.1-x64\\bin\\R.exe'
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'ScriptEngineDefinition_R,r'
-- 	      AND Name = 'exePath'
-- ;


-- not used, but might be of interest
-- UPDATE    prop.Properties
-- SET       Value = FALSE
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'SiteConfig'
--             AND Name = 'sslRequired'
-- ;
--
--UPDATE    prop.Properties
--SET       Value = '8443'
--WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'SiteConfig'
--            AND Name = 'sslPort'
--;

-- can change the site file root
-- UPDATE    prop.Properties
-- SET       Value = 'c:\labkey_data'
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'SiteConfig'
--             AND Name = 'webRoot'
-- ;

-- probably not used, but could put the site in admin mode
-- UPDATE    prop.Properties
-- SET       Value = TRUE
-- WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'SiteConfig'
--             AND Name = 'adminOnlyMode'
-- ;

-- this allows you to promote select users to site admins.  can be useful if giving a local dev a copy of the DB
-- INSERT into    core.Members m
-- (GroupId, UserId) VALUES (-1, (select userId from core.users WHERE email='yourEmail@wisc.edu')
-- ;

--disable notification service
UPDATE  prop.Properties
SET       Value = 'false'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'org.labkey.ldk.notifications.config'
	      AND Name = 'serviceEnabled';

--change reply email for notification service
UPDATE prop.Properties
SET       Value = 'test-onprcitsupport@ohsu.edu'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'org.labkey.ldk.notifications.config'
	      AND Name = 'returnEmail';

--change reply emails
UPDATE prop.Properties
SET       Value = 'test-onprcitsupport@ohsu.edu'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'LookAndFeel'
          AND Name = 'systemEmailAddress';

UPDATE prop.Properties
SET       Value = 'test-onprcitsupport@ohsu.edu'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'SiteConfig'
          AND Name = 'administratorContactEmail';

--disable genetics pipeline
UPDATE prop.Properties
SET       Value = 'false'
WHERE     (SELECT s.Category FROM prop.PropertySets s WHERE s."Set" = Properties."Set") = 'org.labkey.ehr.geneticcalculations'
          AND Name = 'enabled';