
/****** Object:  StoredProcedure [onprc_ehr].[PotentialSire_Insert]    Script Date: 4/22/2020 10:16:39 AM ******/
-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-04-22
-- Description:	SP runs a query to populate the Potential Sire Dataset
-- =============================================


CREATE PROCEDURE [onprc_ehr].[PotentialSire_Insert]

    AS
    BEGIN
        --Potential Sire Query
--This will be used in generation of potential parents
        Truncate table [onprc_ehr].[PotentialSire_source]
        INSERT INTO [onprc_ehr].[PotentialSire_source]
        ([participantId]
        ,[Date]
        ,[Species]
        ,[room]
        ,[cage]
        ,[SireAgeAtTime]
        ,[PotentialSire]
        ,[sireBirth]
        ,[siregender]
        ,[sireSpecies]
        ,[SireDeath]
        ,[created]
        ,[createdBy]
        ,[modified]
        ,[modifiedBy]
        ,[container]
        )
        select
            b.participantid,
            b.date,
            b.species,
            b.room,
            b.cage,
            DateDiff(day, d.birth, b.date) / 365 as SireAgeAtTime,
            h.participantID,
            d.birth as SireBirth,
            d.gender,
            d.species,
            d.death as SireDeath,
            GETDATE(),
            1011,
            GetDate(),
            1011,
            'CD17027B-C55F-102F-9907-5107380A54BE'
        from [studyDataset].[c6d202_birth] b
                 join [studyDataset].[c6d194_housing] h on
            (b.participantId != h.participantId AND
             (h.date <= b.date AND h.enddate >= b.date) AND
             h.room = b.room AND (h.cage = b.cage OR (h.cage is null and b.cage is null))
                --note: this is to always include observed parents
                OR h.participantid = b.dam
                )
                 join [studyDataset].[c6d203_demographics] d on d.participantid = h.participantid
                 join [studyDataset].[c6d203_demographics] d1 on d1.participantID = b.participantid
        WHERE d.gender = 'm' and DateDiff(day, d.birth, b.date) > 912.5 --(2.5 years)
          AND d.species = d1.species






    END
