SELECT
freezerid,
subjectid,
sampletype,
samplesubtype,
samplesource,
processdate,
concentration,
concentration_units,
quantity,
quantity_units,
comment,
dateremoved  --retain this column since downstream queries still filter on it.  more complete fix added to trunk
FROM laboratory.samples
WHERE dateremoved IS NULL