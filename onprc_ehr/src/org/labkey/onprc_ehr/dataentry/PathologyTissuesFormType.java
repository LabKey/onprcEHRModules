package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.EncounterForm;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRPathologyEntryPermission;
import org.labkey.api.ehr.security.EHRSurgeryEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class PathologyTissuesFormType extends EncounterForm
{
    public static final String NAME = "PathologyTissues";
    public static final String LABEL = "Pathology Tissues";

    public PathologyTissuesFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "Pathology", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new PathologyMedicationsFormSection("study", "Drug Administration", "Medications/Treatments"),
                new PathologyFormSection("study", "tissue_samples", "Tissues/Weights"),
                new PathologyFormSection("study", "tissueDistributions", "Tissue Distributions"),
                new PathologyFormSection("study", "measurements", "Measurements")
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Pathology");
            s.addConfigSource("Necropsy");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Pathology.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Necropsy.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/form/field/PathologyCaseNoField.js"));
        addClientDependency(ClientDependency.fromFilePath("onprc_ehr/buttons/pathologyButtons.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/window/CopyFromCaseWindow.js"));
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.add("COPYFROMCASE");

        return ret;
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRPathologyEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
