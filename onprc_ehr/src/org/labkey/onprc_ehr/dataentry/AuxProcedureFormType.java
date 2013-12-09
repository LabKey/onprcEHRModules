package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class AuxProcedureFormType extends TaskForm
{
    public static final String NAME = "Auxiliary Procedures";

    public AuxProcedureFormType(Module owner)
    {
        super(owner, NAME, NAME, "Research", Arrays.<FormSection>asList(
            new TaskFormSection(),
            new AnimalDetailsFormSection(),
            new SimpleGridPanel("study", "encounters", "Procedures"),
            new BloodDrawFormSection(false),
            new WeightFormSection(),
            new BloodTreatmentsFormSection())
        );

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("ResearchProcedures");
        }

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/ResearchProcedures.js"));
    }

    @Override
    protected List<String> getButtonConfigs()
    {
        List<String> ret = super.getButtonConfigs();

        int idx = ret.indexOf("SUBMIT");
        assert idx > -1;

        ret.add(idx, "REVIEW");

        return ret;
    }

    @Override
    protected List<String> getMoreActionButtonConfigs()
    {
        List<String> ret = super.getMoreActionButtonConfigs();
        ret.remove("REVIEW");

        return ret;
    }
}
