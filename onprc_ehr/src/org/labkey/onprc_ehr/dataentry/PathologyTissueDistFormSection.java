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
public class PathologyTissueDistFormSection extends EncounterChildFormSection
{
    public PathologyTissueDistFormSection()
    {
        super("study", "tissueDistributions", "Tissue Distributions", false);

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/window/CopyTissuesWindow.js"));
    }

    @Override
    public List<String> getTbarMoreActionButtons()
    {
        List<String> defaultButtons = super.getTbarMoreActionButtons();

        defaultButtons.add("COPY_TISSUES");

        return defaultButtons;
    }
}
