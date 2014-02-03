package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class MensFormType extends TaskForm
{
    public static final String NAME = "mens";

    public MensFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Menses", "Clinical", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new ClinicalObservationsFormSection()
        ));

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Menses.js"));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("Task");
            s.addConfigSource("Menses");
        }
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
