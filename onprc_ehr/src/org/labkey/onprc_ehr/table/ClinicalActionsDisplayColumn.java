package org.labkey.onprc_ehr.table;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.RenderContext;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.view.template.ClientDependency;

import java.io.IOException;
import java.io.Writer;
import java.util.Collections;
import java.util.Set;

/**

 */
public class ClinicalActionsDisplayColumn extends DataColumn
{
    public ClinicalActionsDisplayColumn(ColumnInfo col)
    {
        super(col);
    }

    public void renderGridCellContents(RenderContext ctx, Writer out) throws IOException
    {
        Object o = getValue(ctx);
        if (o != null)
        {
            out.write("<a onclick=\"EHR.panel.ClinicalManagementPanel.displayActionMenu(this, " + PageFlowUtil.jsString(o.toString()) + ")\">[Actions]");
            out.write("</a>");
        }
    }

    @Override
    public Set<ClientDependency> getClientDependencies()
    {
        return Collections.singleton(ClientDependency.fromFilePath("ehr/ehr_api.lib.xml"));
    }
}
