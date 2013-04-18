--this query is designed to return any dates when allowable blood draw volume changes
--this includes dates of blood draws, plus the date those draws drop off
PARAMETERS(DATE_INTERVAL INTEGER)

SELECT
  b2.id,
  b2.dateOnly,
  b2.quantity,
  DATE_INTERVAL as blood_draw_interval,
  TIMESTAMPADD('SQL_TSI_DAY', (-1 * DATE_INTERVAL), b2.dateOnly) as minDate,
  TIMESTAMPADD('SQL_TSI_DAY', DATE_INTERVAL, b2.dateOnly) as maxDate,

FROM (
  SELECT
    b.id,
    b.dateOnly,
    sum(b.quantity) as quantity

  FROM (
    --find all blood draws within the interval, looking backwards
    SELECT
      b.id,
      b.dateOnly,
      b.quantity,
    FROM study.blood b
    WHERE b.dateOnly >= timestampadd('SQL_TSI_DAY', -1 * DATE_INTERVAL, curdate())

    UNION ALL

    --join 1 row for the current date
    SELECT
      d1.id,
      curdate() as dateOnly,
      0 as quantity,
    FROM study.demographics d1
    WHERE d1.calculated_status = 'Alive'

    UNION ALL

    --add one row for each date when the draw drops off the record
    SELECT
      b.id,
      timestampadd('SQL_TSI_DAY', DATE_INTERVAL, b.dateOnly),
      0 as quantity,
    FROM study.blood b
    WHERE b.dateOnly >= timestampadd('SQL_TSI_DAY', -1 * DATE_INTERVAL, curdate())

  ) b

  GROUP BY b.id, b.dateOnly
) b2