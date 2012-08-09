<%
/*
 * Copyright (c) 2010-2012 LabKey Corporation
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
%>

<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.ViewContext"%>
<%@ page import="org.labkey.api.view.ActionURL" %>
<%@ page import="org.labkey.onprc_ehr.ONPRC_EHRController" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="org.labkey.onprc_ehr.etl.ETL" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>

<%
    ViewContext context = HttpView.currentContext();
    HttpView<ONPRC_EHRController.EtlAdminBean> me = (HttpView<ONPRC_EHRController.EtlAdminBean>) HttpView.currentView();
    ONPRC_EHRController.EtlAdminBean bean = me.getModelBean();
    DateFormat df = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);

%>
<form method="post">

    This page allows configuration of the EHR ETL.  There can only be one instance of the ETL active per site at any time.  Below are explanations for the config properties:
    <p></p>

    <ul>
        <li>
            labkeyUser: A valid LabKey user, which should have admin permission in the EHR folder
        </li>
        <li>
            labkeyContainer: The containerPath to the EHR study
        </li>
        <li>
            jdbcUrl: An example connection string for SQL Server is: jdbc:jtds:sqlserver://localhost:1433;databaseName=DATABASE;user=USERNAME;password=PASSWORD
        </li>
        <li>
            jdbcDriver: The driver name.  For SQLServer, it should be: net.sourceforge.jtds.jdbc.Driver
        </li>
        <li>
            runIntervalInMinutes: The frequency with which the ETL should run
        </li>
        <li>
            defaultLastTimestamp: If the sync has never been performed for a table, this will be used as the last timestamp value
        </li>
        <li>
            shouldAnalyze: If true, an ANALYZE will be performed after the sync. This is useful if a large amount of records will be transferred
        </li>
    </ul>

<table>
<tr>
<td valign="top">
<h2>Settings</h2>

<table>
<tr>
    <td>ETL Enabled</td>
    <td>
        <select name="etlStatus" style="width: 300px">
        <option value="true"
        <% if (ETL.isEnabled()) { %>selected<% } %>
        >Enabled</option>
        <option value="false"
        <% if (!ETL.isEnabled()) { %>selected<% } %>
        >Disabled</option>
        </select>

    </td>
</tr>
<%
    for (String configKey : bean.getConfigKeys())
    {
%>
    <tr>
    <td><%= configKey %></td>
    <td><input style="width: 300px" name="<%= configKey %>" value="<%= bean.getConfig().get(configKey) %>"/></td>
    </tr>
<%
    }
%>

<tr>
<td>shouldAnalyze</td>
<td>
<input type="checkbox" name="shouldAnalyze" <%= bean.shouldAnalyze() ? "checked" : "" %> />
</td>
</tr>

</table>
</td>
<td valign="top">
<h2>Last Sync</h2>
<table>
<%
    for (Map.Entry entry : bean.getTimestamps().entrySet())
    {
%>
    <tr>
    <td><%= entry.getKey() %></td>
    <td><%= df.format(new Date(Long.parseLong(entry.getValue().toString()))) %></td>
    </tr>
<%
    }
%>
</table>
</td>
</tr>
</table>

<input type="submit" value="Save All"/>
<%=textLink("refresh", new ActionURL(ONPRC_EHRController.EtlAdminAction.class, context.getContainer()))%>
</form>
