/*
 * Copyright (c) 2013-2026 LabKey Corporation
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
package org.labkey.GeneticsCore.notification;

import org.apache.logging.log4j.Logger;
import org.labkey.GeneticsCore.GeneticsCoreModule;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ConvertHelper;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.di.DataIntegrationService;
import org.labkey.api.ldk.notification.AbstractNotification;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.logging.LogHelper;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.query.SelectRowsCommand;
import org.labkey.remoteapi.query.SelectRowsResponse;
import org.labkey.remoteapi.query.Sort;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Collections;
import java.util.Date;

public class MhcDataNotification extends AbstractNotification
{
    protected final static Logger _log = LogHelper.getLogger(MhcDataNotification.class, "Messages related to MhcDataNotification");
    protected final static SimpleDateFormat _dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd kk:mm");

    protected NotificationService _ns = NotificationService.get();

    public MhcDataNotification()
    {
        super(ModuleLoader.getInstance().getModule(GeneticsCoreModule.class));
    }

    @Override
    public String getName()
    {
        return "MHC Data Validation";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "MHC Data Alerts: " + _dateTimeFormat.format(new Date());
    }

    @Override
    public String getCategory()
    {
        return "Genetics";
    }

    @Override
    public String getCronString()
    {
        return "0 30 3 ? * *";
    }

    @Override
    public String getScheduleDescription()
    {
        return "daily at 3:30AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed provide a summary of alerts relevant to MHC data";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        getDiscordantGenotypes(c, u, msg);
        getDiscordantCachedResults(c, u, msg);
        getGenotypingWithoutAnalysis(c, u, msg);
        getDiscordantSubjectIds(c, u, msg);
        testPrimeEtl(c, u, msg);

        return msg.toString();
    }

    public void getDiscordantCachedResults(Container c, User u, StringBuilder msg)
    {
        genericQueryCheck(c, u, msg, "geneticscore", "discordantCachedResults", "discordant cached genotypes", new SimpleFilter(FieldKey.fromString("isDiscordantResult"), "DISCORDANT"));
    }

    public void getDiscordantGenotypes(Container c, User u, StringBuilder msg)
    {
        genericQueryCheck(c, u, msg, "geneticscore", "discordantGenotypeResults", "discordant genotyping data", null);
    }

    public void getDiscordantSubjectIds(Container c, User u, StringBuilder msg)
    {
        genericQueryCheck(c, u, msg, "geneticscore", "discordantSubjectIdsGrouped", "records with discordant subject IDs", null);
    }

    public void getGenotypingWithoutAnalysis(Container c, User u, StringBuilder msg)
    {
        genericQueryCheck(c, u, msg, "assay.GenotypeAssay.Genotype", "Data", "genotype results not assigned to an analysis", new SimpleFilter(FieldKey.fromString("analysisId/rowId"), null, CompareType.ISBLANK));
    }

    private void testPrimeEtl(Container c, User u, StringBuilder msg)
    {
        DataIntegrationService.RemoteConnection rc = DataIntegrationService.get().getRemoteConnection("PRIMe", c, _log);
        if (rc == null)
        {
            msg.append("<b>WARNING: Remote connection not found for PRIMe. This indicates a problem with the folder's configuration</b><br>\n");
            return;
        }

        SelectRowsCommand sr = new SelectRowsCommand("geneticscore", "mhc_data");
        sr.setColumns(Collections.singletonList("modified"));
        sr.addSort(new Sort("-modified"));
        sr.setMaxRows(1);
        try
        {
            SelectRowsResponse srr = sr.execute(rc.connection, rc.remoteContainer);

            if (srr.getRowCount().longValue() == 0L)
            {
                msg.append("<b>WARNING: No MHC data found on PRIMe</b><br>\n");
                return;
            }

            Date modified = ConvertHelper.convert(srr.getRows().getFirst().get("modified"), Date.class);
            if (modified == null)
            {
                _log.error("MhcDataNotification returned NULL for the last modified date on PRIMe records");
                return;
            }

            TableInfo ti = getTableInfo(u, c, "geneticscore", "mhc_data_source");
            TableSelector ts = new TableSelector(ti, PageFlowUtil.set("modified"), null, new org.labkey.api.data.Sort("-modified"));
            ts.setMaxRows(1);
            Date sourceLastModified = ts.getObject(Date.class);


            LocalDateTime ld = LocalDateTime.ofInstant(sourceLastModified.toInstant(), ZoneId.systemDefault());
            ld.minusDays(2);
            long minAllowableDate = sourceLastModified.toInstant().toEpochMilli();
            if (sourceLastModified.getTime() < minAllowableDate)
            {
                msg.append("<b>WARNING: The most recent MHC data in PRIMe is more 2 two days before the lastest source data. This probably means the ETL isnt working</b><br>\n");
            }
        }
        catch (CommandException | IOException e)
        {
            _log.error("Error running MhcDataNotification", e);
        }
    }
}
