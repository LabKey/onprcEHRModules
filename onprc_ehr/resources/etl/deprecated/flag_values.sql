SELECT
rp.objectid,
rp.PoolCode as code,
rtrim(ltrim(rp.ShortDescription)) as category,
rtrim(ltrim(rp.Description)) as value,
rp.DateDisabled

FROM Ref_Pool rp
WHERE rp.ts > ?