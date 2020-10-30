/*
* 2017/9/20 Updated statement to handle an issue where records where the qc state was set to deleted, caancelled or pending approval were being
* marked as counts against volume.  The method used here was to determine the current qcstate and exclude these values
 */

Select bd.id,
0 as FutureDraws,
bd.qcState,
COALESCE

(Sum(bd.quantity),0) as PreviousDraws


from blood bd join study.bloodCalcTotalAllowableBlood d on bd.id = d.id
where
bd.dateOnly >= cast(TIMESTAMPADD('SQL_TSI_DAY', -1 * d.species.blood_draw_interval, now()) as date)
AND bd.dateOnly <= cast(curdate() as date)
--and (bd.countsAgainstVolume = true)
and bd.QCState not in (19,22,23,27)
group by bd.id,bd.qcstate

Union

Select bd.id,

COALESCE

(Sum(bd.quantity),0) as FutureDraws,
bd.qcState,
0 as PreviousDraws
from blood bd join study.bloodCalcTotalAllowableBlood d on bd.id = d.id
where  bd.dateOnly <= cast(TIMESTAMPADD('SQL_TSI_DAY', d.species.blood_draw_interval, curdate()) as date)
        AND bd.dateOnly >= cast(curdate() as date)
--and (bd.countsAgainstVolume = true)
and bd.QCState not in (19,22,23,27)
group by bd.id,bd.qcstate
