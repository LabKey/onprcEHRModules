//update to add new data set
package org.labkey.extscheduler;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.resource.Resource;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.settings.AdminConsole;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.extscheduler.query.ExtSchedulerQuerySchema;
//import org.labkey.api.ehr.EHRService;

import java.util.Collection;
import java.util.Collections;
import java.util.Set;

public class ExtSchedulerModule extends ExtendedSimpleModule
{
    public static final String NAME = "ExtScheduler";
    public static final String CONTROLLER_NAME = "extscheduler";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public @Nullable Double getSchemaVersion()
    {
        return 21.003;
    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    @Override
    protected void init()
    {
        addController(CONTROLLER_NAME, ExtSchedulerController.class);
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        return Collections.singleton(ExtSchedulerSchema.NAME);
    }

    @Override
    protected void registerSchemas()
    {
        DefaultSchema.registerProvider(ExtSchedulerSchema.NAME, new DefaultSchema.SchemaProvider(this)
        {
            @Override
            public QuerySchema createSchema(final DefaultSchema schema, Module module)
            {
                return new ExtSchedulerQuerySchema(schema.getUser(), schema.getContainer());
            }
        });
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        //Added 4-19-2023 R.Blasa
//        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("extscheduler/App/view/EventFormAmended.js"), this);
//        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("extscheduler/App/view/ViewportAmended.js"), this);
//        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("extscheduler/App/view/InfoPanelAmended.js"), this);
//        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("extscheduler/App/view/SchedulerAmended.js"), this);
//        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("extscheduler/App/view/ViewportControllerAmended.js"), this);
    }
}
