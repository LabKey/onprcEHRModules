package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormElement;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

/**

 */
public class DocumentArchiveFormSection extends AbstractFormSection
{
    public DocumentArchiveFormSection()
    {
        super("ArrivalInstructions", "Document Archive", "onprc-documentarchivepanel");

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/panel/DocumentArchivePanel.js"));
    }

    @Override
    protected List<FormElement> getFormElements(DataEntryFormContext ctx)
    {
        return Collections.emptyList();
    }
}
