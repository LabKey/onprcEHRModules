--Changed by Kolli - 4/20/22
--Added Linked schema template references

SELECT p.rowid,
       p.objectid,
       p.project,
       pr.name as projectname,
       prc.title as protocol,
       prc.external_id as eIACUCNum,
       inv.lastname || ', ' || inv.firstname as Investigator,
       p.account,
       p.requestorid,
       r.lastname || ', ' || r.firstname as requestor,
       p.vendorid,
       v.name as vendor,
       p.hazardslist,
       p.dobrequired,
       p.darcomments,
       p.comments,
       p.confirmationnum,
       p.vendorcontact,
       p.housingconfirmed,
       p.iacucconfirmed,
       p.created as requestdate,
       p.orderdate,
       p.orderedby
FROM sla.purchase p
Left join publicehr.project pr on p.project = pr.project
Left join publicehr.protocol prc on pr.protocol = prc.protocol
Left join sla.requestors r on r.objectid = p.requestorid
Left join sla.vendors v on v.objectid = p.vendorid
Left join onprc_ehr.investigators inv on inv.rowid = pr.investigatorid
WHERE (
          (SELECT max(rowid) as expr FROM financepublic.dataAccess da
                                          -- current logged in user is the dataAccess user
           WHERE isMemberOf(da.userid)
             -- has access to all data
             AND (da.allData = true
               -- has access to the specified investigatorId and the specified project (if applicable)
               OR (da.investigatorId = pr.investigatorId AND (da.project IS NULL OR da.project = p.project)))
          ) IS NOT NULL
          )

-- SELECT p.rowid,
-- p.objectid,
-- p.project,
-- p.project.name as projectname,
-- p.project.protocol as protocol,
-- p.project.protocol.external_id as eIACUCNum,
-- p.project.investigatorid.lastname || ', ' || p.project.investigatorid.firstname AS investigator,
-- p.account,
-- p.requestorid,
-- p.requestorid.lastname || ', ' || p.requestorid.firstname as requestor,
-- p.vendorid,
-- p.vendorid.name as vendor,
-- p.hazardslist,
-- p.dobrequired,
-- p.darcomments,
-- p.comments,
-- p.confirmationnum,
-- p.vendorcontact,
-- p.housingconfirmed,
-- p.iacucconfirmed,
-- p.created as requestdate,
-- p.orderdate,
-- p.orderedby
-- FROM sla.purchase p
-- WHERE (
--   (SELECT max(rowid) as expr FROM financepublic.dataAccess da
--     -- current logged in user is the dataAccess user
--     WHERE isMemberOf(da.userid)
--     -- has access to all data
--     AND (da.allData = true
--     -- has access to the specified investigatorId and the specified project (if applicable)
--       OR (da.investigatorId = p.project.investigatorId AND (da.project IS NULL OR da.project = p.project)))
--   ) IS NOT NULL
-- )
