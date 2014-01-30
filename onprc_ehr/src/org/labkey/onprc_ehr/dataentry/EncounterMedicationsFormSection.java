package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

import java.util.List;

/**
 * User: bimber
 * Date: 1/10/14
 * Time: 10:09 AM
 */
public class EncounterMedicationsFormSection extends EncounterChildFormSection
{
    public EncounterMedicationsFormSection(String schemaName, String queryName, String label, boolean allowAddDefaults)
    {
        super(schemaName, queryName, label, allowAddDefaults);

        setClientStoreClass("EHR.data.DrugAdministrationRunsClientStore");
        addClientDependency(ClientDependency.fromFilePath("ehr/data/DrugAdministrationRunsClientStore.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromSectionWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SedationWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/DrugAmountWindow.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/SurgeryPostOpMedsWindow.js"));

        setTabName("Medications");
    }

    @Override
    public List<String> getTbarButtons()
    {
        List<String> defaultButtons = super.getTbarButtons();
        if ("drug".equals(getQueryName()) || "Drug Administration".equals(getQueryName()))
        {
            defaultButtons.add(0, "SEDATIONHELPER");
        }

        defaultButtons.add("DRUGAMOUNTHELPER");

        if ("treatment_orders".equals(getQueryName()) || "Treatment Orders".equals(getQueryName()))
        {
            defaultButtons.add("SURGERYMEDS");
        }

        return defaultButtons;
    }
}
