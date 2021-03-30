/****** Housing transfers alert project: By Kolli******/
/*
 Created 3 temp tables to get the list of NHP rooms usage.
 The stored proc manages the addition and deleting data from the temp tables
 at the time of execution via ETL process.
 */
EXEC core.fn_dropifexists 'availableCages_temp','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'availableCagesByRoom_temp','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'roomUtilization_temp','onprc_ehr','TABLE';

GO

-- Create the temp tables
CREATE TABLE [onprc_ehr].[availableCages_temp](
    [location] [varchar](50) NOT NULL,
    [room] [varchar](200) NULL,
    [cage] [varchar](200) NULL,
    [row] [varchar](200) NULL,
    [columnidx] [int] NULL,
    [cage_type] [varchar](200) NULL,
    [lowerCage] [varchar](200) NULL,
    [lower_cage_type] [varchar](200) NULL,
    [divider] [int] NULL,
    [isAvailable] [int] NULL,
    [isMarkedUnavailable] [int] NULL,
    )
;

CREATE TABLE [onprc_ehr].[availableCagesByRoom_temp](
    [room] [varchar](200) NULL,
    [availableCages] [int] NULL,
    [markedUnavailable] [int] NULL
    ) 
;

CREATE TABLE [onprc_ehr].[roomUtilization_temp](
    [room] [nvarchar](200) NULL,
    [availableCages] [int] NULL,
    [cagesUsed] [int] NULL,
    [markedUnavailable] [int] NULL,
    [cagesEmpty] [int] NULL,
    [totalAnimals] [int] NULL
    ) 
;

GO


-- Create the stored proc here
/****** Object:  StoredProcedure [onprc_ehr].[NHPRoomsUsage]   ******/

-- =============================================
-- Author:		Lakshmi Kolli
-- Create date: 3/6/2021
-- Description:	Get the list of NHP rooms usage. The procedure is scheduled using a ETL process
-- to list out the room utilization list at 4pm every day. The list is later used to check against for the
-- empty rooms with the current list of rooms usage.
-- =============================================
CREATE PROCEDURE [onprc_ehr].[NHPRoomsUsage]

AS
BEGIN

----Truncate the temp table first
delete from onprc_ehr.availableCages_temp

----Get the cages list and insert into the temp table
Insert Into onprc_ehr.availableCages_temp(location,room, cage, row, columnidx, cage_type, lowerCage, lower_cage_type, divider, isAvailable, isMarkedUnavailable)
SELECT
    CASE
        WHEN c.cage IS NULL THEN c.room
        ELSE (c.room + '-' + c.cage)
        END as location,
    c.room,
    c.cage,
    (Select cp.row from ehr_lookups.cage_positions cp where c.cage = cp.cage) as row,
    (Select cp.columnIdx from ehr_lookups.cage_positions cp where c.cage = cp.cage) as columnidx,
    c.cage_type,
    lc.cage as lowerCage,
    lc.cage_type as lower_cage_type,
    lc.divider,
    --if the divider on the left-hand cage is separating, then these cages are separate
    --and should be counted.  if there's no left-hand cage, always include
    CASE
        WHEN c.cage_type = 'No Cage' THEN 0
        --WHEN lc.divider.countAsSeparate = 0 THEN false
        WHEN (Select d.countAsSeparate from ehr_lookups.divider_types d where lc.divider = d.rowid) = 0 THEN 0
        ELSE 1
        END as isAvailable,

    CASE
        WHEN (c.status IS NOT NULL AND c.status = 'Unavailable') then 1
        ELSE 0
        END as isMarkedUnavailable

FROM ehr_lookups.cage c
         --find the cage located to the left
         LEFT JOIN ehr_lookups.cage lc ON (lc.cage_type != 'No Cage' and c.room = lc.room and (Select cp.row from ehr_lookups.cage_positions cp where c.cage = cp.cage) = (Select cp.row from ehr_lookups.cage_positions cp where lc.cage = cp.cage) and ((Select cp.columnIdx from ehr_lookups.cage_positions cp where c.cage = cp.cage) - 1) = (Select cp.columnIdx from ehr_lookups.cage_positions cp where lc.cage = cp.cage) )
--WHERE c.room.housingType.value = 'Cage Location'

----Truncate the temp table first
delete from onprc_ehr.availableCagesByRoom_temp

--Get the available cages by room
Insert Into onprc_ehr.availableCagesByRoom_temp(room, availableCages, markedUnavailable)
SELECT
    c.room,
    count(*) as availableCages,
    sum(c.isMarkedUnavailable) as markedUnavailable
FROM onprc_ehr.availableCages_temp c
WHERE c.isAvailable = 1
GROUP BY c.room

----Truncate the temp table first
delete from onprc_ehr.roomUtilization_temp

--Get the rooms usage data
Insert Into onprc_ehr.roomUtilization_temp(room, availableCages, CagesUsed, MarkedUnavailable, CagesEmpty, TotalAnimals)
SELECT
    r.room,
    max(cbr.availableCages) as AvailableCages,
    count(DISTINCT h.cage) as CagesUsed,
    max(cbr.markedUnavailable) as MarkedUnavailable,
    max(cbr.availableCages) - count(DISTINCT h.cage) - max(cbr.markedUnavailable) as CagesEmpty,
    count(DISTINCT h.participantid) as TotalAnimals
FROM ehr_lookups.rooms r
         LEFT JOIN (
            SELECT c.room, c.cage
            FROM ehr_lookups.cage c
            WHERE cage is not null

            --allow for rooms w/o cages
            UNION ALL
            SELECT r.room, null as cage
            FROM ehr_lookups.rooms r
        ) c on (r.room = c.room)
         LEFT JOIN studyDataset.c6d194_housing h ON (r.room=h.room AND (c.cage=h.cage OR (c.cage is null and h.cage is null)) AND (((date <= GETDATE() AND enddate >= GETDATE()) OR (date <= GETDATE() AND enddate is null))))
         LEFT JOIN onprc_ehr.availableCagesByRoom_temp cbr ON (cbr.room = r.room)
WHERE r.datedisabled is null
GROUP BY r.room

END

GO