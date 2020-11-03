/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Updated 2020-04-23 by jones ga
 * changed the source to a insert from a stored procedure
 */
SELECT
    d.RowId,
    d.participantId as id,
    d.Date as birth,
    d.Species,
    d.room as birthroom,
    d.cage as birthCage,
    d.DamAgeAtTime,
    d.potentialDam,
    d.DamBirth,
    d.Damgender,
    d.DamSpecies,
    d.DamDeath

from onprc_ehr.PotentialDam_source d

