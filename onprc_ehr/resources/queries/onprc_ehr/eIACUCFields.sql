/*This dataset provides the fields for the protcol details page
     Includes fields from eiACUC2
     Updated 3/4/2024 jonesga*/





SELECT eIACUCDAta.rowid,
       eIACUCDAta.Protocol_ID,
       eIACUCDAta.BaseProtocol,
       eIACUCDAta.RevisionNumber,
       eIACUCDAta.Template_OID,
       eIACUCDAta.Protocol_OID,
       eIACUCDAta.Protocol_Title,
       eIACUCDAta.PI_ID,
       eIACUCDAta.PI_First_Name,
       eIACUCDAta.PI_Last_Name,
       eIACUCDAta.PI_Email,
       eIACUCDAta.PI_Phone,
       eIACUCDAta.USDA_Level,
       eIACUCDAta.Approval_Date,
       eIACUCDAta.Annual_Update_Due,
       eIACUCDAta.Three_year_Expiration,
       eIACUCDAta.Last_Modified,
       eIACUCDAta.createdby,
       eIACUCDAta.created,
       eIACUCDAta.modifiedby,
       eIACUCDAta.modified,
       eIACUCDAta.PROTOCOL_State,
       eIACUCDAta.PPQ_Numbers,
       eIACUCDAta.Description
FROM eIACUCDAta