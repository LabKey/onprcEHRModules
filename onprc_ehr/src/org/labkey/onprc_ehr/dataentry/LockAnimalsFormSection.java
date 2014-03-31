package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormElement;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;

/**

 */
public class LockAnimalsFormSection extends AbstractFormSection
{
    public LockAnimalsFormSection()
    {
        super("LockAnimals", "Lock Animal Creation", "onprc-lockanimalspanel");

        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/panel/LockAnimalsPanel.js"));
    }

    @Override
    protected List<FormElement> getFormElements(DataEntryFormContext ctx)
    {
        return Collections.emptyList();
    }
}
