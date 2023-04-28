/* Created by Kuirt Randall to meet a need for BCS Scores */

SELECT clinical_observations.Id,
clinical_observations.date,
clinical_observations.category,
clinical_observations.area,
clinical_observations.observation,
clinical_observations.remark,
clinical_observations.taskid,
clinical_observations.performedby,
clinical_observations.requestid,
clinical_observations.Container,
clinical_observations.history,
clinical_observations.isAssignedAtTime,
clinical_observations.isAssignedToProtocolAtTime,
clinical_observations.enteredSinceVetReview,
clinical_observations.QCState
FROM clinical_observations