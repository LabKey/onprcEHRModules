package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
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
public class RecordAmendmentFormType extends TaskForm
{
    public static final String NAME = "RecordAmendment";

    public RecordAmendmentFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Record Amendment", "Clinical", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new SimpleFormPanelSection("study", "Clinical Remarks", "Amendment", false)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("ClinicalDefaults");
            s.addConfigSource("RecordAmendment");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ClinicalDefaults.js"));
        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/RecordAmendment.js"));
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
