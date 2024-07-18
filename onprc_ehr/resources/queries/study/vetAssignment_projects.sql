/*
study.vetAssignment_projects

Replaces:
  * study.vetAssignedResearch
  * study.vetAssignedResearch_project
  * study.vetAssignedResource
  * study.vetAssignedResource_project

Returns a record for each active assignment of an animal ID to a project.
Notes:
  * Animals assigned to multiple projects results in multiple records
  * Animals solely on the P51 are not considered "assigned" in PRIMe
    and won't have records returned by this query
  * Uses Curdate() to avoid issues where an assignment ends on the day this
    query is run. Datetime data is stored in this table with the time as
    00:00:00
  * Returns the actual use category instead of "Project Resource Assigned"
    or "Project Research Assigned"
  * enddate (Release Date) is the first date the animal is NOT on the assignment,
    EXCEPT when enddate = date, in which case enddate is treated as though
    it was the following date for a single-day day lease
 */

SELECT Id
     , project
     , project.protocol.external_id AS Protocol
     , project.protocol.investigatorID.lastname AS PI
     , date
     , enddate
     , project.use_category AS projectType
FROM study.assignment
WHERE Curdate() >= date  /* The assignment has started */
  AND (
    enddate IS NULL            /* Not a day lease or scheduled end of assignment */
    OR Curdate() < enddate   /* The assignment hasn't yet ended */
    OR (Curdate() = enddate AND enddate = date) /* 1-day day lease where date = enddate */
  )
