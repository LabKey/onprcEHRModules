package org.labkey.onprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.User;
import org.labkey.onprc_ehr.ONPRC_EHRModule;

/**
 * User: bimber
 * Date: 7/22/13
 * Time: 11:58 AM
 */
abstract public class AbstractEHRDataSource extends AbstractDataSource
{
    public AbstractEHRDataSource(String schema, String query)
    {
        super(schema, query);
    }

    public AbstractEHRDataSource(String schema, String query, String categoryText, String categoryGroup)
    {
        super(schema, query, categoryText, categoryGroup);
    }

    @Override
    public boolean isAvailable(Container c, User u)
    {
        if (!c.getActiveModules().contains(ModuleLoader.getInstance().getModule(ONPRC_EHRModule.class)))
        {
            return false;
        }

        return super.isAvailable(c, u);
    }
}
