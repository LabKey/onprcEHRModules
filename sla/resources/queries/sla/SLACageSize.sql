/*
 * Copyright (c) 2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

  /*   Created  Blasa    2-13-2015  Provide Distinct SLA Cage Size Reference table */

  select  value
   from  sla.Reference_Data
   Where columnName = 'cagesize'
   order by sort_order


