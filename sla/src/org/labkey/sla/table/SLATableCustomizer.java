package org.labkey.sla.table;

import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.gwt.client.FacetingBehaviorType;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.UserSchema;

/**
 * User: bimber
 * Date: 1/8/14
 * Time: 10:46 AM
 */
public class SLATableCustomizer extends AbstractTableCustomizer
{
    @Override
    public void customize(TableInfo ti)
    {
        EHRService.get().getEHRCustomizer().customize(ti);

        if (ti instanceof AbstractTableInfo)
        {
            customizeColumns((AbstractTableInfo)ti);
        }
    }

    private void customizeColumns(AbstractTableInfo ti)
    {
        Container ehrContainer = EHRService.get().getEHRStudyContainer(ti.getUserSchema().getContainer());
        if (ehrContainer != null)
        {
            var project = ti.getMutableColumn("project");
            if (project != null && !ti.getName().equalsIgnoreCase("project"))
            {
                project.setFacetingBehaviorType(FacetingBehaviorType.ALWAYS_OFF);
                UserSchema ehrSchema = getUserSchema(ti, "ehr", ehrContainer);
                if (ehrSchema != null)
                    project.setFk(QueryForeignKey.from(ehrSchema, ti.getContainerFilter())
                            .container(ehrContainer)
                            .table("project")
                            .key("project")
                            .display("displayName"));
            }

            var chargeId = ti.getMutableColumn("chargeId");
            if (chargeId != null && !ti.getName().equalsIgnoreCase("chargeableItems"))
            {
                UserSchema billingSchema = getUserSchema(ti, "onprc_billing", ehrContainer);
                if (billingSchema != null)
                    chargeId.setFk(QueryForeignKey.from(billingSchema, ti.getContainerFilter())
                            .container(ehrContainer)
                            .table("chargeableItems")
                            .key("rowid")
                            .display("name"));
            }
        }
    }
}
