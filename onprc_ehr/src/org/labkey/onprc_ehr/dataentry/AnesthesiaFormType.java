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

 */
public class AnesthesiaFormType extends TaskForm
{
    public static final String NAME = "Anesthesia";

    public AnesthesiaFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME + " Monitoring", "Clinical", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new AnimalDetailsFormSection(),
                new SimpleGridPanel("study", "encounters", "Procedures"),
                new AnesthesiaFormSection()
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("Anesthesia");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/Anesthesia.js"));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRClinicalEntryPermission.class))
            return false;

        return super.canInsert();
    }

    @Override
    public boolean isVisible()
    {
        return false;
    }
}
