package org.labkey.GeneticsCore;

import org.labkey.api.assay.AssayProvider;
import org.labkey.api.assay.AssayService;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.exp.api.ExpData;
import org.labkey.api.exp.api.ExpRun;
import org.labkey.api.exp.api.ExperimentListener;
import org.labkey.api.gwt.client.AuditBehaviorType;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class GeneticsCoreExpListener implements ExperimentListener
{
    //TODO: restore this if we can change the signature of this method to include User
    //@Override
    //public void beforeRunDelete(ExpProtocol protocol, ExpRun run, User user)
    //{
    //    deleteForRun(user, run, user);
    //}

    @Override
    public void beforeDataDelete(Container c, User user, List<? extends ExpData> data)
    {
        //NOTE: this is only used b/c beforeRunDelete() doesnt pass the User
        Set<ExpRun> runs = data.stream().map(ExpData::getRun).collect(Collectors.toSet());
        if (!runs.isEmpty())
        {
            runs.forEach(run -> {
                deleteForRun(user, run);
            });
        }
    }

    private void deleteForRun(User user, ExpRun run)
    {
        AssayProvider ap = AssayService.get().getProvider(run);
        if (ap == null)
        {
            return;
        }

        TableInfo data = ap.createProtocolSchema(user, run.getContainer(), run.getProtocol(), null).createDataTable(null);

        TableSelector ts = new TableSelector(data, PageFlowUtil.set("RowId", "SubjectId"), new SimpleFilter(FieldKey.fromString("Run"), run.getRowId()), null);
        List<Map<String, Object>> resultRows = new ArrayList<>();
        ts.forEachResults(rs -> {
            resultRows.add(Map.of("RowId", rs.getInt(FieldKey.fromString("RowId")), "SubjectId", rs.getInt(FieldKey.fromString("SubjectId"))));
        });

        if (!resultRows.isEmpty())
        {
            QueryService.get().getDefaultAuditHandler().addAuditEvent(user, run.getContainer(), data, AuditBehaviorType.DETAILED, null, QueryService.AuditAction.DELETE, resultRows, resultRows);
        }
    }
}
