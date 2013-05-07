SELECT
  f.id,
  st.code.meaning as agent,
  f.flag,
  max(st.interval) as testInterval,
  max(s.date) as lastTestDate,
  min(timestampdiff('SQL_TSI_MONTH', s.date, now())) as monthsSinceTest,
  CASE
    WHEN max(s.date) IS NULL THEN 0
    ELSE (max(st.interval) - min(timestampdiff('SQL_TSI_MONTH', s.date, now())))
  END as monthsUntilDue,
FROM study.flags f
JOIN onprc_ehr.serology_test_schedule st ON (st.flag = f.value)
LEFT JOIN study.serology s ON (f.id = s.id AND s.agent = st.code)

WHERE f.enddateCoalesced >= curdate()

GROUP BY f.id, f.flag, st.code.meaning

--PIVOT lastTestDate, monthsSinceTest, monthsUntilDue by agent