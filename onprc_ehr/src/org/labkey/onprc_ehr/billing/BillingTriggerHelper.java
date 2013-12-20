/*
 * Copyright (c) 2013 LabKey Corporation
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
package org.labkey.onprc_ehr.billing;

import org.apache.commons.lang3.time.DateUtils;
import org.labkey.api.data.Aggregate;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.onprc_ehr.ONPRC_EHRBillingUserSchema;
import org.labkey.onprc_ehr.ONPRC_EHRSchema;

import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * User: bimber
 * Date: 11/26/13
 * Time: 4:07 PM
 */
public class BillingTriggerHelper
{
    private Container _container = null;
    private User _user = null;

    public BillingTriggerHelper(int userId, String containerId)
    {
        _user = UserManager.getUser(userId);
        if (_user == null)
            throw new RuntimeException("User does not exist: " + userId);

        _container = ContainerManager.getForId(containerId);
        if (_container == null)
            throw new RuntimeException("Container does not exist: " + containerId);

    }

    private User getUser()
    {
        return _user;
    }

    private Container getContainer()
    {
        return _container;
    }

    private Date _lastInvoiceDate = null;
    private Date getLastInvoiceDate()
    {
        if (_lastInvoiceDate == null)
        {
            UserSchema us = QueryService.get().getUserSchema(getUser(), getContainer(), "onprc_billing_public");
            if (us == null)
            {
                return null;
            }

            TableInfo ti = us.getTable("publicInvoiceRuns");
            if (ti == null)
            {
                return null;
            }

            TableSelector ts = new TableSelector(ti);
            Map<String, List<Aggregate.Result>> aggs = ts.getAggregates(Arrays.asList(new Aggregate(FieldKey.fromString("billingPeriodEnd"), Aggregate.Type.MAX)));
            for (List<Aggregate.Result> ag : aggs.values())
            {
                for (Aggregate.Result r : ag)
                {
                    if (r.getValue() instanceof Date)
                    {
                        _lastInvoiceDate = (Date)r.getValue();
                        if (_lastInvoiceDate != null)
                            _lastInvoiceDate = DateUtils.round(_lastInvoiceDate, Calendar.DATE);
                    }
                }
            }

        }

        return _lastInvoiceDate;
    }

    public boolean isBeforeLastInvoice(Date d)
    {
        Date lastInvoice = getLastInvoiceDate();
        if (lastInvoice == null)
            return false;

        Date toTest = DateUtils.round(new Date(d.getTime()), Calendar.DATE);
        return toTest.before(lastInvoice);
    }

    public void addAuditEntry(String tableName, String objectId, String msg)
    {
        BillingAuditViewFactory.addAuditEntry(getContainer(), getUser(), tableName, objectId, msg);
    }
}
