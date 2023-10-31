package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.TaskForm;
import org.labkey.api.ehr.dataentry.TaskFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;

import java.util.Arrays;

/**
 * User: Kolli
 * Date: 7/7/19
 * Time: 10:36 AM
 */
public class IPCRequestFormType extends TaskForm
{
    public static final String NAME = "IPC SERVICE REQUEST";

    public IPCRequestFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Histology Service Request", "Requests", Arrays.asList(
                new TaskFormSection(),
                new IPC_ServiceRequestDetailsFormSection("Service Request Details"),
                new AnimalDetailssFormSection(),
                new IPC_CassettePrintingFormSection(),
                new IPC_ProcessingEmbeddingFormSection(),
                new IPC_SectioningFormSection(),
                new IPC_StainingFormSection(),
                new IPC_SlidePrintingFormSection(),
                new IPC_OtherFormSection()
        ));

        setStoreCollectionClass("EHR.data.IPCStoreCollection");
        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/data/IPCStoreCollection.js"));
    }

}


