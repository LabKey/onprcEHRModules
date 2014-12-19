package org.labkey.genotypeassays.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.Module;
import org.labkey.api.security.permissions.DeletePermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.view.template.ClientDependency;

/**
 * User: bimber
 * Date: 1/25/14
 * Time: 8:47 AM
 */
public class CacheAnalysesButton extends SimpleButtonConfigFactory
{
    public CacheAnalysesButton(Module owner)
    {
        super(owner, "Cache Results", "GenotypeAssays.window.CacheResultsWindow.showWindow(dataRegionName);");

        setClientDependencies(ClientDependency.fromModuleName("ldk"), ClientDependency.fromPath("genotypeassays/window/CacheResultsWindow.js"));
    }

    public boolean isAvailable(TableInfo ti)
    {
        return super.isAvailable(ti) && ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), DeletePermission.class) && ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), InsertPermission.class) && ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), UpdatePermission.class);
    }
}
