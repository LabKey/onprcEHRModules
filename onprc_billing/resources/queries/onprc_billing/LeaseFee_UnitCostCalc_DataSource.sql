SELECT d.Id,
       d.datefinalized as date, --Validation error - duplicate column 'date', remove the one not needed (for validation error to pass, i've commented out the duplicate column below)
       r.CenterProject as project,
       r.alias as account,
       t.ReleaseDate as enddate, --Validation error - duplicate column 'enddate', remove the one not needed (for validation error to pass, i've commented out the duplicate column below)
       r.ProjectedReleaseCondition as ProjectedReleaseCondition,
       d.releasecondition,
       d.assignCondition as assigncondition,
       d.releaseType,
       d.AgeAtAssignment as AgeAtTime,
       d.ageinyears,
       d.AgeGroup,
       d.BirthAssignment,
       d.BirthType,
       d.AssignmentType,
       d.DayLease,
       d.DayLeaseLength,
       d.MultipleAssignments,
--        d.date, --Validation error -- duplicate column 'date'
       d.projectedRelease,
--        d.enddate, --Validation error -- duplicate column 'enddate'
       d.datefinalized as dateFinalized,
       d.remark as comment,
       d.farate,
       d.removesubsidy,
       d.canRaiseFA,
       r.chargeID as LeaseCharge1, --original lease type
       r.RevisedChargeID as LeaseCharge2,  --Final Leases Type
       t.creditto as CreditAccount


from onprc_billing.leaseFee_demographics d
   --  Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.LeaseFee_Demographics d
         join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_LeaseType t on d.id = t.id and t.assignmentdate = d.date and t.project = d.project
         Join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_rateData r on r.id = d.id and r.projectID = d.project and r.assignmentDate = d.date