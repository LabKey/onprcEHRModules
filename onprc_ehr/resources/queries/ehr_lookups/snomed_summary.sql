SELECT
    s.code,
    s.meaning,
    sc.primaryCategory,
    s.container
FROM ehr_lookups.snomed s
LEFT JOIN ehr_lookups.snomed_subset_codes sc ON s.code = sc.code