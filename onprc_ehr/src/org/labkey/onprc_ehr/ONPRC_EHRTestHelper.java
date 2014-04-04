/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.onprc_ehr;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyService;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * User: bimber
 * Date: 1/7/13
 * Time: 9:05 AM
 */
public class ONPRC_EHRTestHelper
{
    public ONPRC_EHRTestHelper()
    {

    }

    public void testHousingOverlaps(Container c, User u)
    {

    }

    public void testBloodCalculation(Container c, User u)
    {
        Study study = StudyService.get().getStudy(c);
        if (study == null)
            return;

        TableInfo bloodDraws = getStudySchema(c, u).getTable("Blood Draws");
        if (bloodDraws == null)
            return;

        //insert dummy records
        Map<String, Object> record = new HashMap<>();
        Table.insert(u, bloodDraws, record);

        //run query
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("qcstate/label"), "Request: Denied", CompareType.NEQ);
        filter.addCondition(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        TableSelector ts = new TableSelector(bloodDraws, filter, null);

        //verify results
        //TODO
    }

    private UserSchema getStudySchema(Container c, User u)
    {
        return QueryService.get().getUserSchema(u, c, "study");
    }
}
