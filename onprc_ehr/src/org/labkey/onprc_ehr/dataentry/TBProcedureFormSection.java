package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.view.template.ClientDependency;

/**

 */
public class TBProcedureFormSection extends SimpleGridPanel
{
    public TBProcedureFormSection()
    {
        super("study", "encounters", "TB Tests");

        addClientDependency(ClientDependency.fromFilePath("ehr/model/sources/TBProcedure.js"));
        addConfigSource("TBProcedure");
    }
}
