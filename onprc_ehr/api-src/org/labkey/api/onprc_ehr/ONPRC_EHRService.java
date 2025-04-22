package org.labkey.api.onprc_ehr;

import org.labkey.api.services.ServiceRegistry;

public interface ONPRC_EHRService
{
    static ONPRC_EHRService get()
    {
        return ServiceRegistry.get().getService(ONPRC_EHRService.class);
    }

    static void setInstance(ONPRC_EHRService impl)
    {
        ServiceRegistry.get().registerService(ONPRC_EHRService.class, impl);
    }

    Object getAnimalDetailsFormSection();
}
