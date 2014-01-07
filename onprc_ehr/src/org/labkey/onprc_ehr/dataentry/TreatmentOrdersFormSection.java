package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class TreatmentOrdersFormSection extends SimpleFormSection
{
    public TreatmentOrdersFormSection()
    {
        this(EHRService.FORM_SECTION_LOCATION.Body);
    }

    public TreatmentOrdersFormSection(EHRService.FORM_SECTION_LOCATION location)
    {
        super("study", "Treatment Orders", "Medication/Treatment Orders", "ehr-gridpanel");
        setClientStoreClass("EHR.data.DrugAdministrationRunsClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromSectionWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SedationWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/DrugAmountWindow.js"));

        setLocation(location);
        setTabName("Medications");
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        defaultButtons.add("DRUGAMOUNTHELPER");

        return defaultButtons;
    }
}
