//update to add new data set
//update to trigger change
package org.labkey.extscheduler;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.module.Module;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.QuerySchema;
import org.labkey.extscheduler.query.ExtSchedulerQuerySchema;

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
        return 23.002;
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
}
