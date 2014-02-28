package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.AbstractFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.ExtendedAnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.NonStoreFormSection;
import org.labkey.api.ehr.dataentry.SimpleFormPanelSection;
import org.labkey.api.ehr.dataentry.SimpleFormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.ehr.security.EHRBehaviorEntryPermission;
import org.labkey.api.ehr.security.EHRClinicalEntryPermission;
import org.labkey.api.module.Module;
import org.labkey.api.query.Queryable;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 12/3/13
 * Time: 8:13 PM
 */
public class BehaviorExamFormType extends TaskForm
{
    @Queryable
    public static final String NAME = "BSU Exam";
    public static final String LABEL = "BSU Exam";

    public BehaviorExamFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, LABEL, "BSU", Arrays.<FormSection>asList(
                new TaskFormSection(),
                new ExtendedAnimalDetailsFormSection(),
                new ClinicalObservationsFormSection(EHRService.FORM_SECTION_LOCATION.Body)
        ));

        for (FormSection s : this.getFormSections())
        {
            s.addConfigSource("BehaviorDefaults");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/BehaviorDefaults.js"));
    }

    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), EHRBehaviorEntryPermission.class))
            return false;

        return super.canInsert();
    }
}
