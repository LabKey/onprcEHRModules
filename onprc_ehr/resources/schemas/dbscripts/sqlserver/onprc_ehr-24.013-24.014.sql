

/*
**
** 	Created by
**      Blasa  		10/8/2025          Process to update birth record;s geogrphic origin data.  The "Genetic Ancestry"
**                                      geographic_origin information must override the birth's geographic origin values.
**

**
**
**
**
*/

CREATE Procedure onprc_ehr.p_BirthGeographicOriginUpdates

    as


BEGIN

   ----- Process data

  IF exists (select *  From studydataset.c6d202_birth bir, studydataset.c6d512_geneticancestry b where bir.participantid = b.participantid
    And b.enddate is null
    and bir.qcstate = 18
    and b.qcstate = 18
    And bir.geographic_origin <> b.result
    And b.result is not null
              )



    BEGIN

   ---- Update birth geographic origin

   Update bir
   set bir.geographic_origin = b.result,
       bir.modified = getdate(),
       bir.modifiedby = b.modifiedby    ---- ancestry staff

    From studydataset.c6d202_birth bir, studydataset.c6d512_geneticancestry b
    where bir.participantid = b.participantid
    And b.enddate is null
    And bir.qcstate = 18
    And b.qcstate = 18
    And bir.geographic_origin <> b.result
    And b.result is not null


    If @@Error <> 0
         GoTo Err_Proc

END  ---- if





RETURN 0


    Err_Proc:
                    -------Error Generated, process stopped
	RETURN 1


END

GO


