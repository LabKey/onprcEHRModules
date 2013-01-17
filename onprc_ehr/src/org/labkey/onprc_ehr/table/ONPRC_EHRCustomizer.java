/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
package org.labkey.onprc_ehr.table;

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.TableCustomizer;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.view.HttpView;

import java.io.IOException;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 12/7/12
 * Time: 2:22 PM
 */
public class ONPRC_EHRCustomizer implements TableCustomizer
{
    private Map<String, UserSchema> _userSchemas;

    public ONPRC_EHRCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        _userSchemas = new HashMap<String, UserSchema>();

        if (table instanceof AbstractTableInfo)
        {
            customizeColumns((AbstractTableInfo) table);

            if (matches(table, "study", "Animal"))
            {
                customizeAnimalTable((AbstractTableInfo)table);
            }
            else if (matches(table, "study", "Clinical Encounters"))
            {
                customizeEncounters((AbstractTableInfo) table);
            }
            else if (matches(table, "ehr", "project"))
            {
                customizeProjects((AbstractTableInfo) table);
            }
        }
    }

    private void customizeColumns(AbstractTableInfo ti)
    {
        ColumnInfo project = ti.getColumn("project");
        if (project != null && !ti.getName().equalsIgnoreCase("project"))
        {
            if (project.getFk() == null)
            {
                UserSchema us = getUserSchema(ti, "ehr");
                if (us != null)
                    project.setFk(new QueryForeignKey(us, "project", "project", "name"));
            }
        }

        ColumnInfo account = ti.getColumn("account");
        if (account != null && !ti.getName().equalsIgnoreCase("accounts"))
        {
            account.setLabel("Alias");
            if (account.getFk() == null)
            {
                UserSchema us = getUserSchema(ti, "onprc_billing");
                if (us != null)
                    account.setFk(new QueryForeignKey(us, "accounts", "account", "account"));
            }
        }

        boolean found = false;
        for (String field : new String[]{"grant", "grantNumber"})
        {
            if (found)
                continue; //a table should never contain both of these anyway

            ColumnInfo grant = ti.getColumn(field);
            if (grant!= null)
            {
                found = true;
                if (!ti.getName().equalsIgnoreCase("grants") && grant.getFk() == null)
                {
                    UserSchema us = getUserSchema(ti, "onprc_billing");
                    if (us != null)
                        grant.setFk(new QueryForeignKey(us, "grants", "grantNumber", "grantNumber"));
                }
            }
        }

        ColumnInfo room = ti.getColumn("room");
        if (room != null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null){
                room.setFk(new QueryForeignKey(us, "rooms", "room", "room"));
            }

            room.setLabel("Room");
        }

        ColumnInfo chargeId = ti.getColumn("chargeId");
        if (chargeId != null)
        {
            UserSchema us = getUserSchema(ti, "onprc_billing");
            if (us != null){
                chargeId.setFk(new QueryForeignKey(us, "chargeableItems", "rowid", "name"));
            }
            chargeId.setLabel("Charge Name");
        }

        ColumnInfo snomed = ti.getColumn("snomed");
        if (snomed != null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null){
                snomed.setFk(new QueryForeignKey(us, "snomed", "code", "meaning"));
            }
            snomed.setLabel("SNOMED");
        }

        ColumnInfo procedureId = ti.getColumn("procedureId");
        if (procedureId != null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null){
                procedureId.setFk(new QueryForeignKey(us, "procedures", "rowid", "name"));
            }
            procedureId.setLabel("Procedure");
        }

        found = false;
        for (String field : new String[]{"investigator", "investigatorId"})
        {
            if (found)
                continue; //a table should never contain both of these anyway

            ColumnInfo investigator = ti.getColumn(field);
            if (investigator != null)
            {
                found = true;
                investigator.setLabel("Investigator");

                if (!ti.getName().equalsIgnoreCase("investigators") && investigator.getJavaClass().equals(Integer.class))
                {
                    UserSchema us = getUserSchema(ti, "onprc_ehr");
                    if (us != null){
                        investigator.setFk(new QueryForeignKey(us, "investigators", "rowid", "lastname"));
                    }
                }
                investigator.setLabel("Investigator");
            }
        }

        ColumnInfo fiscalAuthority = ti.getColumn("fiscalAuthority");
        if (fiscalAuthority != null)
        {
            UserSchema us = getUserSchema(ti, "onprc_billing");
            if (us != null){
                fiscalAuthority.setFk(new QueryForeignKey(us, "fiscalAuthorities", "rowid", "lastName"));
            }
            fiscalAuthority.setLabel("Fiscal Authority");
        }
    }

    private void customizeAnimalTable(AbstractTableInfo ds)
    {
        if (ds.getColumn("activeFlags") != null)
            return;

        UserSchema us = getStudyUserSchema(ds);
        if (us == null){
            return;
        }

        ColumnInfo col = getWrappedIdCol(us, ds, "activeFlags", "flagsPivoted");
        col.setLabel("Active Flags");
        //col.setDescription("");
        ds.addColumn(col);

        ColumnInfo col2 = getWrappedIdCol(us, ds, "activeNotes", "notesPivoted");
        col2.setLabel("Active Notes");
        //col.setDescription("");
        ds.addColumn(col2);
    }

    private void customizeEncounters(AbstractTableInfo ti)
    {
        if (ti.getColumn("history") != null)
            return;

        ColumnInfo ci = new WrappedColumn(ti.getColumn("objectid"), "history");
        ci.setDisplayColumnFactory(new DisplayColumnFactory()
        {
            @Override
            public DisplayColumn createRenderer(final ColumnInfo colInfo)
            {
            return new DataColumn(colInfo){

                public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
                {
                    String lsid = (String)ctx.get("objectid");
                    out.write("<a href=\"javascript:void(0);\" onclick=\"EHR.Utils.showEncounterHistory('" + lsid + "', this);\">Display History</a>");
                }

                public boolean isSortable()
                {
                    return false;
                }

                public boolean isFilterable()
                {
                    return false;
                }

                public boolean isEditable()
                {
                    return false;
                }
            };
            }
        });
        ci.setIsUnselectable(false);
        ci.setLabel("History");

        ti.addColumn(ci);
    }

    private void customizeProjects(AbstractTableInfo ti)
    {
        ti.setTitleColumn("name");

        ti.getColumn("inves").setHidden(true);
        ti.getColumn("inves2").setHidden(true);
        ti.getColumn("reqname").setHidden(true);
        ti.getColumn("research").setHidden(true);
        ti.getColumn("avail").setHidden(true);

        ColumnInfo invest = ti.getColumn("investigatorId");
        invest.setHidden(false);
        UserSchema us = getUserSchema(ti, "onprc_ehr");
        if (us != null)
            invest.setFk(new QueryForeignKey(us, "investigators", "rowid", "lastname"));
    }

    private ColumnInfo getWrappedIdCol(UserSchema us, AbstractTableInfo ds, String name, String queryName)
    {
        String ID_COL = "Id";
        WrappedColumn col = new WrappedColumn(ds.getColumn(ID_COL), name);
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new QueryForeignKey(us, queryName, ID_COL, ID_COL));

        return col;
    }

    private UserSchema getStudyUserSchema(AbstractTableInfo ds)
    {
        return getUserSchema(ds, "study");
    }

    public UserSchema getUserSchema(AbstractTableInfo ds, String name)
    {
        if (!(ds instanceof FilteredTable))
        {
            return null;
        }

        if (_userSchemas.containsKey(name))
            return _userSchemas.get(name);

        User u;
        Container c = ((FilteredTable)ds).getContainer();

        if (HttpView.hasCurrentView()){
            u = HttpView.currentContext().getUser();
        }
        else
        {
            u = EHRService.get().getEHRUser(c);
        }

        if (u == null)
            return null;

        UserSchema us = QueryService.get().getUserSchema(u, c, name);
        if (us != null)
            _userSchemas.put(name, us);

        return us;
    }

    private boolean matches(TableInfo ti, String schema, String query)
    {
        return ti.getSchema().getName().equalsIgnoreCase(schema) && ti.getName().equalsIgnoreCase(query);
    }
}
