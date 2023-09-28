/*
study.vetAssignment_projects.sql

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
    query is run
  * Returns the actual use category instead of "Project Resource Assigned"
    or "Project Research Assigned"
 */

SELECT Id
     , project
     , project.protocol.external_id AS Protocol
     , project.protocol.investigatorID.lastname AS PI
     , date
     , enddate
     , project.use_category AS projectType
FROM study.assignment
WHERE date <= Curdate()
  AND (
    enddate IS NULL
   OR enddate >= Curdate()
    )