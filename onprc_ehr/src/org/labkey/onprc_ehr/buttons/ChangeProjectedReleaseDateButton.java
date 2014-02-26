package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.buttons.MarkCompletedButton;
import org.labkey.api.module.Module;
import org.labkey.api.util.PageFlowUtil;

/**

 */
public class ChangeProjectedReleaseDateButton extends MarkCompletedButton
{
    public ChangeProjectedReleaseDateButton(Module owner)
    {
        super(owner, "study", "assignment", "Change Projected Release Date");
    }

    @Override
    protected String getJsHandler(TableInfo ti)
    {
        ColumnInfo col = ti.getColumn("enddate");
        String xtype = "datefield";
        if (col != null && col.getFormat().contains("HH"))
            xtype = "xdatetime";

        String pkColName = null;
        if (ti.getPkColumnNames() != null && ti.getPkColumnNames().size() == 1)
        {
            pkColName = ti.getPkColumnNames().get(0);
        }

        return "EHR.window.MarkCompletedWindow.buttonHandler(dataRegionName, " + PageFlowUtil.jsString(_schemaName) + ", " + PageFlowUtil.jsString(_queryName) + ", " + PageFlowUtil.jsString(xtype) + ", " + PageFlowUtil.jsString(pkColName) + ", false, 'projectedRelease');";
    }
}
