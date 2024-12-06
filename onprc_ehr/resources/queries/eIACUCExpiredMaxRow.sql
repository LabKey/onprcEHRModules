Select
    p.*



from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
where p.RowID in
(Select MaxRowID from eIACUCExpiredMaxRow r where r.rowID = p.Rowid )