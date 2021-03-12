package org.labkey.GeneticsCore;

import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.laboratory.AbstractDataProvider;
import org.labkey.api.laboratory.LaboratoryService;
import org.labkey.api.laboratory.NavItem;
import org.labkey.api.laboratory.QueryImportNavItem;
import org.labkey.api.laboratory.SummaryNavItem;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.User;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.template.ClientDependency;

import java.util.Collections;
import java.util.List;
import java.util.Set;

public class GeneticsCoreDataProvider extends AbstractDataProvider
{
    @Override
    public String getName()
    {
        return "Genetics Core";
    }

    @Override
    public ActionURL getInstructionsUrl(Container c, User u)
    {
        return null;
    }

    @Override
    public List<NavItem> getDataNavItems(Container c, User u)
    {
        return Collections.singletonList(new QueryImportNavItem(this, GeneticsCoreModule.NAME, "mhc_data", "MHC Typing Data", LaboratoryService.NavItemCategory.data, "Genetics", null));
    }

    @Override
    public List<NavItem> getSampleNavItems(Container c, User u)
    {
        return Collections.emptyList();
    }

    @Override
    public List<NavItem> getSettingsItems(Container c, User u)
    {
        return Collections.emptyList();
    }

    @Override
    public JSONObject getTemplateMetadata(ViewContext ctx)
    {
        return new JSONObject();
    }

    @Override
    public Set<ClientDependency> getClientDependencies()
    {
        return null;
    }

    @Override
    public Module getOwningModule()
    {
        return ModuleLoader.getInstance().getModule(GeneticsCoreModule.NAME);
    }

    @Override
    public List<SummaryNavItem> getSummary(Container c, User u)
    {
        return Collections.emptyList();
    }

    @Override
    public List<NavItem> getSubjectIdSummary(Container c, User u, String subjectId)
    {
        return Collections.emptyList();
    }
}
