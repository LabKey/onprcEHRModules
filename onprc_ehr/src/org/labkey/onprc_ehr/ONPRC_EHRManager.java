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

import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.module.ModuleProperty;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.Queryable;
import org.labkey.api.security.User;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * User: bimber
 * Date: 9/21/13
 * Time: 9:55 AM
 */
public class ONPRC_EHRManager
{
    private static ONPRC_EHRManager _instance = new ONPRC_EHRManager();

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
    public static final String TMB_PROJECT = "0300";
    @Queryable
    public static final String VET_USER_GROUP = "DCM Veterinarians";
    @Queryable
    public static final String VET_REVIEW = "Vet Review";
    @Queryable
    public static final String TECH_REVIEW = "Reviewed";
    @Queryable
    public static final String REPLACED_SOAP = "Replaced SOAP";

    private ONPRC_EHRManager()
    {

    }

    public static ONPRC_EHRManager get()
    {
        return _instance;
    }
}

