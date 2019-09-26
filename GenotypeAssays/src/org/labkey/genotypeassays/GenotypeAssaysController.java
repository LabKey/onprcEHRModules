/*
 * Copyright (c) 2012 LabKey Corporation
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

package org.labkey.genotypeassays;

import org.json.JSONArray;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.ConfirmAction;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.TableInfo;
import org.labkey.api.exp.api.ExpProtocol;
import org.labkey.api.exp.api.ExperimentService;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.util.Pair;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.HtmlView;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GenotypeAssaysController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(GenotypeAssaysController.class);

    public GenotypeAssaysController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    public class MigrateLegacySSPAction extends ConfirmAction<Object>
    {
        public void validateCommand(Object form, Errors errors)
        {

        }

        @Override
        public ModelAndView getConfirmView(Object form, BindException errors) throws Exception
        {
            DbSchema schema = DbSchema.get("SSP_Assay");
            if (schema == null)
                return new HtmlView("Either the legacy SSP module has not been installed, or it has already been removed");
            else
                return new HtmlView("This allows an admin to copy any primers stored in the original SSP Assay module into the new genotyping module.  Any data has already been copied.  Do you want to continue?");
        }

        public boolean handlePost(Object form, BindException errors) throws Exception
        {
            try
            {
                DbSchema schema = DbSchema.get("SSP_Assay");
                if (schema == null)
                    return true; //module not installed

                TableInfo primers = schema.getTable("primers");
                if (primers == null)
                    return true;

                SqlExecutor sql = new SqlExecutor(schema);

                sql.execute("INSERT INTO genotypeassays.primer_pairs (primerName, ref_nt_name, ref_nt_id, shortName, forwardPrimer, reversePrimer, createdBy, created, modifiedby, modified) " +
                    "SELECT s.primerName, s.ref_nt_name, s.ref_nt_id, s.shortName, s.forwardPrimer, s.reversePrimer, s.createdBy, s.created, s.modifiedby, s.modified " +
                    "FROM ssp_assay.primers s " +
                    "LEFT JOIN genotypeassays.primer_pairs p ON (p.primerName = s.primerName) " +
                    "WHERE p.primerName is null");

                sql.execute("DROP TABLE ssp_assay.primers");
                sql.execute("DROP TABLE ssp_assay.ssp_result_types");
                sql.execute("DROP SCHEMA ssp_assay");

                return true;
            }
            catch (Exception e)
            {
                errors.reject(ERROR_MSG, e.getMessage());
                return false;
            }
        }

        public URLHelper getSuccessURL(Object form)
        {
            return getContainer().getStartURL(getUser());
        }
    }

    @RequiresPermission(UpdatePermission.class)
    public class CacheAnalysesAction extends MutatingApiAction<CacheAnalysesForm>
    {
        public ApiResponse execute(CacheAnalysesForm form, BindException errors)
        {
            Map<String, Object> resultProperties = new HashMap<>();

            //first verify permission to delete
            if (form.getAlleleNames() != null)
            {
                try
                {
                    ExpProtocol protocol = ExperimentService.get().getExpProtocol(form.getProtocolId());
                    if (protocol == null)
                    {
                        errors.reject(ERROR_MSG, "Unknown protocol: " + form.getProtocolId());
                        return null;
                    }

                    Pair<List<Integer>, List<Integer>> ret = GenotypeAssaysManager.get().cacheAnalyses(getViewContext(), protocol, form.getAlleleNames());
                    resultProperties.put("runsCreated", ret.first);
                    resultProperties.put("runsDeleted", ret.second);
                }
                catch (IllegalArgumentException e)
                {
                    errors.reject(ERROR_MSG, e.getMessage());
                    return null;
                }
            }
            else
            {
                errors.reject(ERROR_MSG, "No alleles provided");
                return null;
            }

            resultProperties.put("success", true);

            return new ApiSimpleResponse(resultProperties);
        }
    }

    public static class CacheAnalysesForm
    {
        private String[] _alleleNames;
        private String _json;
        private int _protocolId;

        public String[] getAlleleNames()
        {
            return _alleleNames;
        }

        public void setAlleleNames(String[] alleleNames)
        {
            _alleleNames = alleleNames;
        }

        public int getProtocolId()
        {
            return _protocolId;
        }

        public void setProtocolId(int protocolId)
        {
            _protocolId = protocolId;
        }

        public String getJson()
        {
            return _json;
        }

        public void setJson(String json)
        {
            _json = json;
        }
    }

    @RequiresPermission(UpdatePermission.class)
    public class CacheHaplotypesAction extends MutatingApiAction<CacheAnalysesForm>
    {
        public ApiResponse execute(CacheAnalysesForm form, BindException errors)
        {
            Map<String, Object> resultProperties = new HashMap<>();

            //first verify permission to delete
            if (form.getJson() != null)
            {
                try
                {
                    ExpProtocol protocol = ExperimentService.get().getExpProtocol(form.getProtocolId());
                    if (protocol == null)
                    {
                        errors.reject(ERROR_MSG, "Unknown protocol: " + form.getProtocolId());
                        return null;
                    }

                    Pair<List<Integer>, List<Integer>> ret = GenotypeAssaysManager.get().cacheHaplotypes(getViewContext(), protocol, new JSONArray(form.getJson()));
                    resultProperties.put("runsCreated", ret.first);
                    resultProperties.put("runsDeleted", ret.second);
                }
                catch (IllegalArgumentException e)
                {
                    errors.reject(ERROR_MSG, e.getMessage());
                    return null;
                }
            }
            else
            {
                errors.reject(ERROR_MSG, "No data provided");
                return null;
            }

            resultProperties.put("success", true);

            return new ApiSimpleResponse(resultProperties);
        }
    }
}