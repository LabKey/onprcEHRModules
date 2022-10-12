
SELECT d.Id,
d.allele,
d.shortName,
d.totalTests,
d.result,
d.type

FROM  StudyDetails_RandalData s, MHCData.MHC_Data_Unified d
where (Cast(s.rh as varchar(25)) = Cast(d.id as varchar(25)))