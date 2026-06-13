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
package org.labkey.onprc_billing;

import org.apache.logging.log4j.Level;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.DbScope;
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
import org.labkey.api.util.GUID;
import org.labkey.api.util.JunitUtil;
import org.labkey.api.util.TestContext;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * User: bimber
 * Date: 9/21/13
 * Time: 9:55 AM
 */
public class ONPRC_BillingManager
{
    private static final ONPRC_BillingManager _instance = new ONPRC_BillingManager();
    public static final String BillingContainerPropName = "BillingContainer";
    public static final String IssuesContainerPropName = "IssuesContainer";
    public static final String SLAContainerPropName = "SLAContainer";

    @Queryable
        public static final String DAY_LEASE_MAX_DURATION = "14";
    @Queryable
    public static final String DAY_LEASE_NAME = "One Day Lease";
    @Queryable
    public static final String TMB_LEASE_NAME = "Animal Lease Fee - TMB";
    @Queryable
    public static final String LEASE_FEE_ADJUSTMENT = "Lease Fee Adjustment";
    @Queryable
    public static final String LEASE_SETUP_FEES = "Lease Setup Fees";

    private ONPRC_BillingManager()
    {

    }

    public static ONPRC_BillingManager get()
    {
        return _instance;
    }

    public List<String> deleteBillingRuns(User user, Container container, Collection<String> pks, boolean testOnly)
    {
        TableInfo invoiceRuns = ONPRC_BillingSchema.getInstance().getSchema().getTable(ONPRC_BillingSchema.TABLE_INVOICE_RUNS);
        TableInfo invoicedItems = ONPRC_BillingSchema.getInstance().getSchema().getTable(ONPRC_BillingSchema.TABLE_INVOICED_ITEMS);
        TableInfo miscCharges = ONPRC_BillingSchema.getInstance().getSchema().getTable(ONPRC_BillingSchema.TABLE_MISC_CHARGES);

        //create filters
        SimpleFilter invoiceRunFilter = createContainerScopedInFilter(container, "invoiceId", pks);
        SimpleFilter miscChargesFilter = createContainerScopedInFilter(container, "invoiceId", pks);
        SimpleFilter invoiceRunsFilter = createContainerScopedInFilter(container, "objectid", pks);

        //perform the work
        List<String> ret = new ArrayList<>();
        if (testOnly)
        {
            TableSelector tsRuns = new TableSelector(invoicedItems, invoiceRunFilter, null);
            ret.add(tsRuns.getRowCount() + " records from invoiced items");

            TableSelector tsMiscCharges2 = new TableSelector(miscCharges, miscChargesFilter, null);
            ret.add(tsMiscCharges2.getRowCount() + " records from misc charges will be removed from the deleted invoice, which means they will be picked up by the next billing period.  They are not deleted.");
        }
        else
        {
            try (DbScope.Transaction transaction = ExperimentService.get().ensureTransaction())
            {
                Table.delete(invoicedItems, invoiceRunFilter);

                TableSelector tsMiscCharges2 = new TableSelector(miscCharges, Collections.singleton("objectid"), miscChargesFilter, null);
                String[] miscChargesIds = tsMiscCharges2.getArray(String.class);
                for (String objectid : miscChargesIds)
                {
                    Map<String, Object> map = new CaseInsensitiveHashMap<>();
                    map.put("invoiceId", null);
                    Table.update(user, miscCharges, map, objectid, SimpleFilter.createContainerFilter(container), Level.WARN);
                }

                Table.delete(invoiceRuns, invoiceRunsFilter);

                transaction.commit();
            }
        }

        return ret;
    }

    private SimpleFilter createContainerScopedInFilter(Container container, String columnName, Collection<String> values)
    {
        return SimpleFilter.createContainerFilter(container).addInClause(FieldKey.fromString(columnName), values);
    }

    public Container getBillingContainer(Container c)
    {
        Module billing = ModuleLoader.getInstance().getModule(ONPRC_BillingModule.NAME);
        ModuleProperty mp = billing.getModuleProperties().get(BillingContainerPropName);
        String path = mp.getEffectiveValue(c);
        if (path == null)
            return null;

        return ContainerManager.getForPath(path);

    }

    public Container getSLADataFolder(Container c)
    {
        Module m = ModuleLoader.getInstance().getModule("sla");
        ModuleProperty mp = m.getModuleProperties().get(SLAContainerPropName);
        String path = mp.getEffectiveValue(c);
        if (path == null)
            return null;

        return ContainerManager.getForPath(path);

    }

    public static class TestCase extends Assert
    {
        private static final String FOLDER_A = "ONPRCBillingDeleteTestA";
        private static final String FOLDER_B = "ONPRCBillingDeleteTestB";

        private User _user;
        private Container _containerA;
        private Container _containerB;
        private String _runIdA;
        private String _runIdB;

        @Before
        public void setUp()
        {
            _user = TestContext.get().getUser();
            deleteTestFolders();

            Container junit = JunitUtil.getTestContainer();
            _containerA = createBillingFolder(junit, FOLDER_A);
            _containerB = createBillingFolder(junit, FOLDER_B);

            _runIdA = insertBillingRun(_containerA);
            _runIdB = insertBillingRun(_containerB);
        }

        @After
        public void tearDown()
        {
            deleteTestFolders();
        }

        @Test
        public void testDeleteBillingRunsIsContainerScoped()
        {
            ONPRC_BillingManager manager = ONPRC_BillingManager.get();
            ONPRC_BillingSchema schema = ONPRC_BillingSchema.getInstance();

            // A testOnly preview issued from container A targeting container B's run must not see container B's rows.
            for (String summary : manager.deleteBillingRuns(_user, _containerA, List.of(_runIdB), true))
                assertTrue("Preview from another container should count 0 rows, but got: " + summary, summary.startsWith("0 "));

            // An actual delete issued from container A targeting container B's run must leave container B untouched.
            manager.deleteBillingRuns(_user, _containerA, List.of(_runIdB), false);
            assertEquals("invoiceRuns row in container B should survive a delete issued from container A", 1, containerRowCount(getTable(schema, ONPRC_BillingSchema.TABLE_INVOICE_RUNS), _containerB));
            assertEquals("invoicedItems row in container B should survive a delete issued from container A", 1, containerRowCount(getTable(schema, ONPRC_BillingSchema.TABLE_INVOICED_ITEMS), _containerB));
            assertEquals("miscCharges row in container B should still reference its invoice", 1, miscChargesWithInvoiceCount(_containerB));

            // Positive control: deleting a run from its own container removes its rows.
            manager.deleteBillingRuns(_user, _containerA, List.of(_runIdA), false);
            assertEquals("invoiceRuns row in container A should be deleted", 0, containerRowCount(getTable(schema, ONPRC_BillingSchema.TABLE_INVOICE_RUNS), _containerA));
            assertEquals("invoicedItems row in container A should be deleted", 0, containerRowCount(getTable(schema, ONPRC_BillingSchema.TABLE_INVOICED_ITEMS), _containerA));
            assertEquals("miscCharges row in container A should be detached from the deleted invoice", 0, miscChargesWithInvoiceCount(_containerA));
            assertEquals("miscCharges row in container A should not be deleted", 1, containerRowCount(getTable(schema, ONPRC_BillingSchema.TABLE_MISC_CHARGES), _containerA));
        }

        private Container createBillingFolder(Container parent, String name)
        {
            Container c = ContainerManager.createContainer(parent, name, _user);
            Set<Module> active = new HashSet<>(c.getActiveModules());
            active.add(ModuleLoader.getInstance().getModule(ONPRC_BillingModule.NAME));
            c.setActiveModules(active, _user);
            return c;
        }

        private String insertBillingRun(Container c)
        {
            ONPRC_BillingSchema schema = ONPRC_BillingSchema.getInstance();
            String runId = GUID.makeGUID();

            Map<String, Object> run = new CaseInsensitiveHashMap<>();
            run.put("objectid", runId);
            run.put("runDate", new Date());
            run.put("billingPeriodStart", new Date());
            run.put("billingPeriodEnd", new Date());
            run.put("container", c.getId());
            Table.insert(_user, getTable(schema, ONPRC_BillingSchema.TABLE_INVOICE_RUNS), run);

            Map<String, Object> invoicedItem = new CaseInsensitiveHashMap<>();
            invoicedItem.put("objectid", GUID.makeGUID());
            invoicedItem.put("invoiceId", runId);
            invoicedItem.put("container", c.getId());
            Table.insert(_user, getTable(schema, ONPRC_BillingSchema.TABLE_INVOICED_ITEMS), invoicedItem);

            Map<String, Object> miscCharge = new CaseInsensitiveHashMap<>();
            miscCharge.put("objectid", GUID.makeGUID());
            miscCharge.put("invoiceId", runId);
            miscCharge.put("container", c.getId());
            Table.insert(_user, getTable(schema, ONPRC_BillingSchema.TABLE_MISC_CHARGES), miscCharge);

            return runId;
        }

        private TableInfo getTable(ONPRC_BillingSchema schema, String tableName)
        {
            return schema.getSchema().getTable(tableName);
        }

        private long containerRowCount(TableInfo table, Container c)
        {
            return new TableSelector(table, SimpleFilter.createContainerFilter(c), null).getRowCount();
        }

        private long miscChargesWithInvoiceCount(Container c)
        {
            SimpleFilter filter = SimpleFilter.createContainerFilter(c);
            filter.addCondition(FieldKey.fromParts("invoiceId"), null, CompareType.NONBLANK);
            return new TableSelector(getTable(ONPRC_BillingSchema.getInstance(), ONPRC_BillingSchema.TABLE_MISC_CHARGES), filter, null).getRowCount();
        }

        private void deleteTestFolders()
        {
            Container junit = JunitUtil.getTestContainer();
            for (String name : List.of(FOLDER_A, FOLDER_B))
            {
                Container c = junit.getChild(name);
                if (c != null)
                    ContainerManager.delete(c, _user);
            }
        }
    }
}
