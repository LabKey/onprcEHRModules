/*
 * Copyright (c) 2013-2017 LabKey Corporation
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

import org.labkey.api.data.Container;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.query.Queryable;
import org.labkey.api.security.User;
import org.labkey.api.settings.LookAndFeelProperties;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * User: bimber
 * Date: 9/21/13
 * Time: 9:55 AM
 */
public class ONPRC_EHRManager
{
    private static ONPRC_EHRManager _instance = new ONPRC_EHRManager();
    public static final String VetReviewStartDateProp = "VetReviewStartDate";

    @Queryable
    public static final String AUC_RESERVED = "AUC Reserved";
    @Queryable
    public static final String PENDING_SOCIAL_GROUP = "Pending Social Group";
    @Queryable
    public static final String PENDING_ASSIGNMENT = "Pending Assignment";
    @Queryable
    public static final String BASE_GRANT_PROJECT = "0492";
    @Queryable
    public static final String U42_PROJECT = "0492-02";
    @Queryable
    public static final String U24_PROJECT = "0492-03";
    @Queryable
    public static final String TMB_PROJECT = "0300";
    @Queryable
    public static final String VET_USER_GROUP = "DCM Veterinarians";
    @Queryable
    public static final String VET_REVIEW = "Vet Review";
    @Queryable
    public static final String TECH_REVIEW = "Reviewed";
    @Queryable
    public static final String REPLACED_SOAP = "Replaced SOAP";
    @Queryable
    public static final String RECORD_AMENDMENT = "Record Amendment";
    @Queryable
    public static final String TB_TEST_INTRADERMAL = "TB Test Intradermal";
    @Queryable
    public static final String TB_TEST_SEROLOGIC = "TB Test Serologic";
    @Queryable
    public static final String SURGERY_SOAP_CATEGORY = "Surgery";
    @Queryable
    public static final String CLINICAL_SOAP_CATEGORY = "Clinical";
    @Queryable
    public static final String INFANT_PER_DIEM = "Per Diem Infants < 181 Days";
    @Queryable
    public static final String QUARANTINE_PER_DIEM = "Per Diem Quarantine";
    @Queryable
    public static final Integer INFANT_PER_DIEM_AGE = 181;
    @Queryable
    public static final String NURSERY_AREA = "Nursery Area";
    @Queryable
    public static final Double BASE_SUBSIDY = 0.47;

    @Queryable
    public static final String CAGE_HEIGHT_EXEMPTION_FLAG = "Obese, or Pregnant";
    @Queryable
    public static final String CAGE_WEIGHT_EXEMPTION_FLAG = "Obese, or Pregnant";
    @Queryable
    public static final String CAGE_MEDICAL_EXEMPTION_FLAG = "Medical";

    private ONPRC_EHRManager()
    {

    }

    public static ONPRC_EHRManager get()
    {
        return _instance;
    }

    private String LOCK_PROP_KEY = getClass().getName() + "||animalLock";

    public void lockAnimalCreation(Container c, User u, Boolean lock, Integer startingId, Integer idCount)
    {
        PropertyManager.PropertyMap map = PropertyManager.getWritableProperties(c, LOCK_PROP_KEY, true);
        map.put("lockedBy", u.getDisplayName(u));
        map.put("locked", lock.toString());
        map.put("lockDate", new SimpleDateFormat(LookAndFeelProperties.getInstance(c).getDefaultDateTimeFormat()).format(new Date()));
        map.put("startingId", (startingId == null ? null : startingId.toString()));
        map.put("idCount", (idCount == null ? null : idCount.toString()));

        map.save();
    }

    public Map<String, Object> getAnimalLockProperties(Container c)
    {
        Map<String, String> props = PropertyManager.getProperties(c, LOCK_PROP_KEY);
        Map<String, Object> ret = new HashMap<>();
        if (props != null && !props.isEmpty())
        {
            if (props.containsKey("lockedBy"))
                ret.put("lockedBy", props.get("lockedBy"));

            if (props.containsKey("locked"))
                ret.put("locked", Boolean.parseBoolean(props.get("locked")));

            if (props.containsKey("lockDate"))
            {
                try
                {
                    ret.put("lockDate", new SimpleDateFormat(LookAndFeelProperties.getInstance(c).getDefaultDateTimeFormat()).parse(props.get("lockDate")));
                }
                catch (ParseException e)
                {
                    //ignore
                }
            }

            if (props.containsKey("startingId"))
                ret.put("startingId", Integer.parseInt(props.get("startingId")));

            if (props.containsKey("idCount"))
                ret.put("idCount", Integer.parseInt(props.get("idCount")));
        }

        return ret;
    }
}

