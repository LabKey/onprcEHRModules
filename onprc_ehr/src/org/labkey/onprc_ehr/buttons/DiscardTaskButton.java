package org.labkey.onprc_ehr.buttons;

import org.labkey.api.data.TableInfo;
import org.labkey.api.ldk.table.SimpleButtonConfigFactory;
import org.labkey.api.module.Module;
import org.labkey.api.security.permissions.DeletePermission;

/**
 * User: bimber
 * Date: 8/2/13
 * Time: 12:26 PM
 */
public class DiscardTaskButton extends SimpleButtonConfigFactory
{
    public DiscardTaskButton(Module owner)
    {
        super(owner, "Discard Tasks", "EHR.DatasetButtons.discardTasks(dataRegionName);");
    }

    public boolean isAvailable(TableInfo ti)
    {
        return super.isAvailable(ti) && ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), DeletePermission.class);
    }
}

