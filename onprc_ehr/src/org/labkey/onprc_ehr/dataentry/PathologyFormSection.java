package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormElement;
import org.labkey.api.query.FieldKey;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 11/20/13
 * Time: 7:52 PM
 */
public class PathologyFormSection extends EncounterChildFormSection
{
    public PathologyFormSection(String schemaName, String queryName, String label)
    {
        super(schemaName, queryName, label, false);

        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/SnomedCodesEditor.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/grid/SnomedColumn.js"));
    }

//    @Override
//    public List<String> getTbarButtons()
//    {
//        List<String> defaultButtons = super.getTbarButtons();
//
//
//        return defaultButtons;
//    }

    @Override
    protected List<FormElement> getFormElements(DataEntryFormContext ctx)
    {
        List<FormElement> ret = super.getFormElements(ctx);

        for (TableInfo ti : getTables(ctx))
        {
            ColumnInfo col = ti.getColumn(FieldKey.fromString("codesRaw"));
            if (col != null)
            {
                ret.add(FormElement.createForColumn(col));
            }
        }

        return ret;
    }
}
