--Changed by Kolli - 4/20/22
--Added Linked schema template references

SELECT pd.*

FROM sla.purchase p, sla.purchasedetails pd, publicehr.project pr, publicehr.protocol prc
WHERE p.objectid = pd.purchaseid and p.project = pr.project

FROM sla.purchasedetails pd
         Left join sla.purchase p on p.objectid = pd.purchaseid
         Left join publicehr.project pr on p.project = pr.project
         Left join publicehr.protocol prc on pr.protocol = prc.protocol
WHERE p.project = pr.project

  AND (
    (SELECT max(rowid) as expr FROM financepublic.dataAccess da
                                    -- current logged in user is the dataAccess user
     WHERE isMemberOf(da.userid)
       -- has access to all data
       AND (da.allData = true
         -- has access to the specified investigatorId and the specified project (if applicable)
         OR (da.investigatorId = pr.investigatorId AND (da.project IS NULL OR da.project = p.project)))
    ) IS NOT NULL
    )

-- SELECT pd.*
-- FROM sla.purchase p, sla.purchasedetails pd, publicehr.project pr, publicehr.protocol prc
--
-- WHERE p.objectid = pd.purchaseid and p.project = pr.project
--   AND (
--     (SELECT max(rowid) as expr FROM financepublic.dataAccess da
--                                     -- current logged in user is the dataAccess user
--      WHERE isMemberOf(da.userid)
--        -- has access to all data
--        AND (da.allData = true
--          -- has access to the specified investigatorId and the specified project (if applicable)
--          OR (da.investigatorId = pr.investigatorId AND (da.project IS NULL OR da.project = p.project)))
--     ) IS NOT NULL
--     )




-- SELECT pd.*
-- FROM sla.purchase p, sla.purchasedetails pd
-- WHERE p.objectid = pd.purchaseid
-- AND (
--   (SELECT max(rowid) as expr FROM financePublic.onprc_billing.dataAccess da
--     -- current logged in user is the dataAccess user
--     WHERE isMemberOf(da.userid)
--     -- has access to all data
--     AND (da.allData = true
--     -- has access to the specified investigatorId and the specified project (if applicable)
--       OR (da.investigatorId = p.project.investigatorId AND (da.project IS NULL OR da.project = p.project)))
--   ) IS NOT NULL
-- )
