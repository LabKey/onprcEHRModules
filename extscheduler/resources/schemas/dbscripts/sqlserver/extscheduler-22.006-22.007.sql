--2021-05-25 Modified view  to Address modification of Processing to Events DB
--Created by jonesga
--update 2021-06-16 to add to new build

EXEC core.fn_dropifexists 'vw_Covid19DCMDaily','extscheduler','VIEW';
/****** Object:  View [extscheduler].[vw_Covid19DCMDaily]    Script Date: 5/25/2021 5:34:40 AM ******/
SET ANSI_NULLS ON
    GO

SET QUOTED_IDENTIFIER ON
    GO

CREATE OR ALTER VIEW [extscheduler].[vw_Covid19DCMDaily]
AS
SELECT        Id, StartDate, Container, Comments, ResourceId, Quantity
FROM            extscheduler.Events AS e
WHERE        (Quantity > 1) AND (Comments NOT LIKE '%-%') AND (DateDisabled IS NULL) AND (Container IN
                    (SELECT        Container  FROM            extscheduler.Events
                      WHERE        (ResourceId = 67)))

