/*
 * Copyright (c) 2012-2018 LabKey Corporation
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

import jakarta.servlet.http.HttpServletResponse;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.ReadOnlyApiAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.view.ActionURL;
import org.labkey.api.study.Dataset;
import org.labkey.api.study.StudyService;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Objects;

/**
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:56 PM
 */
public class ONPRC_EHRController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(ONPRC_EHRController.class);

    public ONPRC_EHRController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    public static class GetNavItemsAction extends ReadOnlyApiAction<Object>
    {
        @Override
        public ApiResponse execute(Object form, BindException errors)
        {
            Map<String, Object> resultProperties = new HashMap<>();

            resultProperties.put("labs", getSection("/ONPRC/Labs"));
            resultProperties.put("admin", getSection("/ONPRC/Admin"));
            resultProperties.put("cores", getSection("/ONPRC/Core Facilities"));
            resultProperties.put("dcm", getSection("/ONPRC/DCM"));

            //Created: 12-7-2016 -- Update by jones ga to change target
            resultProperties.put("scheduler", getSection("/ONPRC/ResourceScheduler"));

            //Added 6-5-2016 Blasa
            resultProperties.put("sla", getSection("/ONPRC/SLA"));

            //Added by kollil 5/7/2019
            resultProperties.put("reservation", getSection("/ONPRC/Room Reservations"));

            //for now, EHR is hard coded
            List<JSONObject> ehr = new ArrayList<>();
            Container ehrContainer = ContainerManager.getForPath("/ONPRC/EHR");
            if (ehrContainer != null)
            {
                JSONObject json = new JSONObject();
                json.put("name", "Main Page");
                json.put("path", ehrContainer.getPath());
                json.put("url", ehrContainer.getStartURL(getUser()).toString());
                json.put("canRead", ehrContainer.hasPermission(getUser(), ReadPermission.class));
                ehr.add(json);

                json = new JSONObject();
                json.put("name", "Animal History");
                json.put("path", ehrContainer.getPath());
                json.put("url", new ActionURL("ehr", "animalHistory", ehrContainer).toString());
                json.put("canRead", ehrContainer.hasPermission(getUser(), ReadPermission.class));
                ehr.add(json);

                json = new JSONObject();
                json.put("name", "ONPRC Animal Search");
                json.put("path", ehrContainer.getPath());
                json.put("url", new ActionURL("ehr", "animalSearch", ehrContainer).toString());
                json.put("canRead", ehrContainer.hasPermission(getUser(), ReadPermission.class));
                ehr.add(json);

            }

            resultProperties.put("ehr", ehr);
            resultProperties.put("success", true);

            return new ApiSimpleResponse(resultProperties);
        }

        private List<JSONObject> getSection(String path)
        {
            List<JSONObject> ret = new ArrayList<>();
            Container mainContainer = ContainerManager.getForPath(path);
            if (mainContainer != null)
            {
                for (Container c : mainContainer.getChildren())
                {
                    JSONObject json = new JSONObject();
                    json.put("name", c.getName());
                    json.put("title", c.getTitle());
                    json.put("path", c.getPath());
                    json.put("url", c.getStartURL(getUser()));
                    json.put("canRead", c.hasPermission(getUser(), ReadPermission.class));
                    ret.add(json);

                    Container publicContainer = ContainerManager.getForPath(c.getPath() + "/Public");
                    if (publicContainer != null)
                    {
                        JSONObject childJson = new JSONObject();
                        childJson.put("name", publicContainer.getName());
                        childJson.put("title", publicContainer.getTitle());
                        childJson.put("path", publicContainer.getPath());
                        childJson.put("url", publicContainer.getStartURL(getUser()));
                        childJson.put("canRead", publicContainer.hasPermission(getUser(), ReadPermission.class));

                        json.put("publicContainer", childJson);
                    }
                }
            }

            return ret;
        }
    }

    /**
     * Used to get the HTTP Session ID for SSRS integration. See ONPRC.Utils.getSsrsParams().
     * This allows the cookie to be marked as HTTP-only
     */
    @RequiresPermission(ReadPermission.class)
    public static class GetSessionIdAction extends MutatingApiAction<Object>
    {
        @Override
        public Object execute(Object o, BindException errors)
        {
            return Map.of("SessionId", getViewContext().getRequest().getSession(true).getId());
        }
    }

    @RequiresPermission(ReadPermission.class)
    public static class GetAnimalLockAction extends ReadOnlyApiAction<Object>
    {
        @Override
        public ApiResponse execute(Object form, BindException errors)
        {
            return new ApiSimpleResponse(ONPRC_EHRManager.get().getAnimalLockProperties(getContainer()));
        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public static class SetAnimalLockAction extends MutatingApiAction<LockAnimalForm>
    {
        @Override
        public ApiResponse execute(LockAnimalForm form, BindException errors)
        {
            ///Added by Lakshmi on 02/26/2015: This is server side validation code to check if the Birth/Arrival screens are locked or not.
            //If already locked: show the lock results
            //If not locked: Check if its locked and display the lock results instead of locking the screen again.
            Map<String, Object> props = ONPRC_EHRManager.get().getAnimalLockProperties(getContainer());
            if (!Boolean.TRUE.equals(props.get("locked") ) || (!form.isLock()) )
            {
                ONPRC_EHRManager.get().lockAnimalCreation(getContainer(), getUser(), form.isLock(), form.getStartingId(), form.getIdCount());
            }

            return new ApiSimpleResponse(ONPRC_EHRManager.get().getAnimalLockProperties(getContainer()));
        }
    }

    public static class LockAnimalForm
    {
        private boolean _lock;
        private Integer _startingId;
        private Integer _idCount;

        public boolean isLock()
        {
            return _lock;
        }

        public void setLock(boolean lock)
        {
            _lock = lock;
        }

        public Integer getIdCount()
        {
            return _idCount;
        }

        public void setIdCount(Integer idCount)
        {
            _idCount = idCount;
        }

        public Integer getStartingId()
        {
            return _startingId;
        }

        public void setStartingId(Integer startingId)
        {
            _startingId = startingId;
        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class PopulateCaseNumbersAction extends MutatingApiAction<Object>
    {
        private String _casesProvisionedName;

        @Override
        public void validateForm(Object o, Errors errors)
        {
            super.validateForm(o, errors);

            StudyService ss = StudyService.get();
            if (ss == null)
            {
                errors.reject(ERROR_REQUIRED, "No study");
                return;
            }

            int datasetId = ss.getDatasetIdByName(getContainer(), "cases");
            Dataset dataset = ss.getDataset(getContainer(), datasetId);

            if (dataset == null)
            {
                errors.reject(ERROR_REQUIRED, "Cases dataset not found.");
                return;
            }

            Domain domain = dataset.getDomain();
            if (domain == null)
            {
                errors.reject(ERROR_REQUIRED, "Cases dataset domain not found.");
                return;
            }

            _casesProvisionedName = domain.getStorageTableName();
            if (_casesProvisionedName == null)
            {
                errors.reject(ERROR_REQUIRED, "Cases dataset provisioned name not found.");
            }
        }

        @Override
        public ApiResponse execute(Object form, BindException errors) throws SQLException
        {
            Container c = EHRService.get().getEHRStudyContainer(getContainer());
            TableInfo ti = QueryService.get().getUserSchema(getUser(), c, "study").getTable("cases");

            SQLFragment sqlStart = new SQLFragment("UPDATE c SET c.caseNo = updates.caseNo FROM studydataset.");
            sqlStart.appendIdentifier(_casesProvisionedName);
            sqlStart.append(" c JOIN (VALUES ");

            SQLFragment sqlEnd = new SQLFragment(") AS updates(dsrowid, caseNo) ");
            sqlEnd.append("ON c.dsrowid = updates.dsrowid");

            logger.info("Starting case number updates.");

            // Stream cases with no case number, sorted by date
            SimpleFilter filter = SimpleFilter.createContainerFilter(getContainer());
            filter.addCondition(FieldKey.fromParts("caseNo"), null, CompareType.ISBLANK);
            ResultSet rs = new TableSelector(ti, filter, new Sort("date")).getResultSet(false, false);

            boolean newBatch = true;
            int counter = 0;
            SQLFragment sql = new SQLFragment().append(sqlStart);

            while( rs.next() )
            {
                if (newBatch) {
                    newBatch = false;
                }
                else {
                    sql.append(",");
                }
                sql.append("(?, ?)");
                sql.add(rs.getInt("dsrowid"));
                sql.add(ONPRC_EHRManager.get().getNextCaseNo(c));
                counter++;

                // Batch boundary
                if (counter % 1000 == 0)
                {
                    newBatch = true;
                    sql.append(sqlEnd);

                    new SqlExecutor(ti.getSchema()).execute(sql);

                    logger.info(counter + " total case numbers added.");

                    sql = new SQLFragment().append(sqlStart);
                }
            }

            if (!newBatch)
            {
                sql.append(sqlEnd);
                new SqlExecutor(ti.getSchema()).execute(sql);
            }

            JSONObject ret = new JSONObject();
            ret.put("rows", counter);
            ret.put("success", true);

            logger.info("Case number update completed. " + counter + " total case numbers updated.");


            return new ApiSimpleResponse(ret);
        }
    }

    public static class SnomedForm
    {
        private String _subset;
        private String _snomed;

        public String getSubset()
        {
            return _subset;
        }

        public void setSubset(String subset)
        {
            _subset = subset;
        }

        public String getSnomed()
        {
            return _snomed;
        }

        public void setSnomed(String snomed)
        {
            _snomed = snomed;
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class GetSnomedAction extends ReadOnlyApiAction<SnomedForm>
    {
        @Override
        public ApiResponse execute(SnomedForm form, BindException errors)
        {
            SQLFragment sql = new SQLFragment();
            if (form.getSubset() != null)
            {
                sql.append("SELECT sn.code FROM ehr_lookups.snomed sn ");
                sql.append("LEFT JOIN ehr_lookups.snomed_subset_codes ssc ");
                sql.append("ON sn.code = ssc.code ");
                sql.append("WHERE ssc.primaryCategory = ? AND sn.container = ? AND soundex(sn.meaning) = soundex(?)");
                sql.add(form.getSubset());
                sql.add(getContainer());
                sql.add(form.getSnomed());
            }
            else
            {
                sql.append("SELECT sn.code FROM ehr_lookups.snomed sn ");
                sql.append("WHERE sn.container = ? AND soundex(sn.meaning) = soundex(?)");
                sql.add(getContainer());
                sql.add(form.getSnomed());
            }

            List<String> results = new SqlSelector(QueryService.get().getUserSchema(getUser(), getContainer(), "ehr_lookups").getDbSchema(), sql).getArrayList(String.class);
            JSONArray array = new JSONArray(results);
            JSONObject obj = new JSONObject();
            obj.put("snomeds", array);

            return new ApiSimpleResponse(obj);
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class SaveSnomedAction extends MutatingApiAction<SnomedForm>
    {
        private Integer _count;
        private String _prefix;
        private Map<String, Object>[] _snomedMatches;

        private String hasExactMatch(SnomedForm form)
        {
            SQLFragment sql = new SQLFragment("SELECT sn.code FROM ehr_lookups.snomed sn ");
            sql.append("LEFT JOIN ehr_lookups.snomed_subset_codes ssc ");
            sql.append("ON sn.code = ssc.code ");
            sql.append("WHERE ssc.primaryCategory = ? AND sn.container = ? AND sn.meaning = ?");
            sql.add(form.getSubset());
            sql.add(getContainer());
            sql.add(form.getSnomed());

            List<String> results = new SqlSelector(QueryService.get().getUserSchema(getUser(), getContainer(), "ehr_lookups").getDbSchema(), sql).getArrayList(String.class);
            return results.isEmpty() ? null : results.get(0);
        }

        private Map<String, Object>[] findSnomed(SnomedForm form)
        {
            SQLFragment sql = new SQLFragment("SELECT sn.code, ssc.primaryCategory FROM ehr_lookups.snomed sn ");
            sql.append("LEFT JOIN ehr_lookups.snomed_subset_codes ssc ");
            sql.append("ON sn.code = ssc.code ");
            sql.append("WHERE sn.container = ? AND sn.meaning = ?");
            sql.add(getContainer());
            sql.add(form.getSnomed());

            return new SqlSelector(QueryService.get().getUserSchema(getUser(), getContainer(), "ehr_lookups").getDbSchema(), sql).getMapArray();
        }

        @Override
        public void validateForm(SnomedForm form, Errors errors)
        {
            super.validateForm(form, errors);

            UserSchema usOnprc = new ONPRC_EHRUserSchema(getUser(), getContainer());
            TableInfo snomedCount = usOnprc.getTable("snomed_counter");
            TableSelector ts = new TableSelector(snomedCount, PageFlowUtil.set("count", "prefix"), new SimpleFilter(FieldKey.fromString("subset"), form.getSubset()), null);
            Map<String, Object>[] results = ts.getMapArray();

            if (results.length == 0)
            {
                errors.reject(ERROR_REQUIRED, "The counter for SNOMED codes for subset " + form.getSubset() + " not found in onprc_ehr.snomed_counter. Contact your administrator.");
            }
            else
            {
                String matchCode = hasExactMatch(form);
                if (matchCode != null)
                {
                    errors.reject(ERROR_UNIQUE, "SNOMED code " + matchCode + " already exists with the meaning '" + form.getSnomed() + "' and subset '" + form.getSubset() + "' in container " + getContainer().getPath() + ".");
                }
                else
                {
                    Set<String> codes = new HashSet<>();
                    _snomedMatches = findSnomed(form);
                    for (Map<String, Object> snomedResult : _snomedMatches)
                    {
                        codes.add((String)snomedResult.get("code"));
                    }

                    if (codes.size() > 1)
                    {
                        String dupes = Arrays.stream(_snomedMatches).reduce("", (acc, map) -> acc + map.toString() + "\n", String::concat);
                        errors.reject(ERROR_UNIQUE, "There are multiple existing matches. Cannot proceed with adding this SNOMED. Contact your administrator to add this SNOMED. Matches: \n" + dupes);
                    }
                    else
                    {
                        _count = ((Integer) results[0].get("count"));
                        _prefix = ((String) results[0].get("prefix"));
                    }
                }
            }
        }

        @Override
        public ApiResponse execute(SnomedForm form, BindException errors)
        {
            JSONObject ret = new JSONObject();
            if (_snomedMatches.length > 0)
            {
                String sameSnomed = Arrays.stream(_snomedMatches).reduce("", (acc, map) -> acc + map.toString(), String::concat);
                ret.put("code", _snomedMatches[0].get("code"));
                ret.put("meaning", form.getSnomed());
                ret.put("status", "SNOMED exists");
                ret.put("matches", sameSnomed);
            }
            else
            {
                String code = _prefix + String.format("%04d", _count);
                Map<String, Object> row = new HashMap<>();
                row.put("code", code);
                row.put("meaning", form.getSnomed());
                row.put("container", getContainer());

                UserSchema us = QueryService.get().getUserSchema(getUser(), getContainer(), "ehr_lookups");
                TableInfo snomedTi = us.getDbSchema().getTable("snomed");
                Table.insert(getUser(), snomedTi, row);

                row = new HashMap<>();
                row.put("code", code);
                row.put("primaryCategory", form.getSubset());
                row.put("container", getContainer());

                TableInfo snomedSubsetTi = us.getDbSchema().getTable("snomed_subset_codes");
                Table.insert(getUser(), snomedSubsetTi, row);

                row = new HashMap<>();
                row.put("subset", form.getSubset());
                row.put("count", _count + 1);
                row.put("container", getContainer());

                UserSchema usOnprc = new ONPRC_EHRUserSchema(getUser(), getContainer());
                TableInfo snomedCounterTi = usOnprc.getDbSchema().getTable("snomed_counter");
                Table.update(getUser(), snomedCounterTi, row, form.getSubset());

                ret.put("code", code);
                ret.put("meaning", form.getSnomed());
                ret.put("status", "success");
            }
            return new ApiSimpleResponse(ret);
        }
    }
}
