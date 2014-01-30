--added to facilitate the split billing code into a separate module from ONPRC_EHR.
--this should cause the server to think all existing scripts were in fact run, even though they ran as the onprc_ehr module
INSERT INTO core.SqlScripts (Created, Createdby, Modified, Modifiedby, FileName, ModuleName)
SELECT Created, Createdby, Modified, Modifiedby, FileName, 'ONPRC_Billing' as ModuleName
FROM core.SqlScripts
WHERE FileName LIKE 'onprc_billing-%'AND ModuleName = 'ONPRC_EHR';