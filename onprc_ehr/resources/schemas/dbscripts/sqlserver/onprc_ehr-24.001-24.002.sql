-- =================================================================================================
-- Adds the fields needed from eIACUC2 to her.protocols: By, Jonesga
-- Created on: 2/13/2024
/* Description: Adds fields used in eiACUC to Protocol table to allow hyperlink
   between protocol and eIACUC2 using the template_oid field
 */
-- =================================================================================================
Drop COLUMN IF EXISTS Template_OID;
Alter Table ehr.protocol Add Column Template_oid varchat(100);
Drop COLUMN IF EXISTS Protocol_oid;
Alter Table ehr.protocol Add Column Protocol_oid varchat(100);
Drop COLUMN IF EXISTS Protocol_state;
Alter Table ehr.protocol Add Column Protocol_state varchat(100);
Drop COLUMN IF EXISTS PPQ_Number;
Alter Table ehr.protocol Add Column PPQ_Number varchat(100);
