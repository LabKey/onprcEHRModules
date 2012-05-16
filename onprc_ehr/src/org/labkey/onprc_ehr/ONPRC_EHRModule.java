package org.labkey.onprc_ehr;

import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.view.WebPartFactory;

import java.util.Collection;
import java.util.Collections;

/**
 * Created by IntelliJ IDEA.
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:52 PM
 */
public class ONPRC_EHRModule extends DefaultModule
{
    public static final String NAME = "ONPRC_EHR";
    public static final String CONTROLLER_NAME = "onprc_ehr";

    public String getName()
    {
        return NAME;
    }

    public double getVersion()
    {
        return 0.00;
    }

    public boolean hasScripts()
    {
        return true;
    }

    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return Collections.emptyList();
    }

    protected void init()
    {
        addController(CONTROLLER_NAME, ONPRC_EHRController.class);
    }

    @Override
    public void startup(ModuleContext moduleContext)
    {

    }
}
