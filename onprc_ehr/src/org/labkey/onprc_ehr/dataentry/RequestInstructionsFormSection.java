package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormElement;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

/**
 * User: bimber
 * Date: 6/9/13
 * Time: 4:15 PM
 */
public class RequestInstructionsFormSection extends AbstractFormSection
{
    public RequestInstructionsFormSection()
    {
        super("RequestInstructions", "Instructions", "onprc-requestinstructionspanel");

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/panel/RequestInstructionsPanel.js"));
    }

    @Override
    protected List<FormElement> getFormElements(DataEntryFormContext ctx)
    {
        return Collections.emptyList();
    }
}
