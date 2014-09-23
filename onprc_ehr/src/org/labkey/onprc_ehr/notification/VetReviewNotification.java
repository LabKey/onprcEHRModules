package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by bimber on 9/18/2014.
 */
public class VetReviewNotification extends ColonyAlertsNotification
{
    public VetReviewNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Vet Review Notification";
    }

    @Override
    public String getEmailSubject()
    {
        return "Vet Alerts: " + _dateTimeFormat.format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 0 15 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "daily at 3PM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed notify vets of any records needing review";
    }

    public String getMessage(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        vetRecordsUnderReview(c, u, msg);
        animalsWithoutAssignedVet(c, u, msg);

        return msg.toString();
    }

    public void vetRecordsUnderReview(Container c, User u, final StringBuilder msg)
    {
        int duration = 7;

        TableInfo ti = QueryService.get().getUserSchema(u, c, "study").getTable("demographics");
        final Map<FieldKey, ColumnInfo> cols = QueryService.get().getColumns(ti, PageFlowUtil.set(
                FieldKey.fromString("Id"),
                FieldKey.fromString("calculated_status"),
                FieldKey.fromString("earliestRemarkSinceReview"),
                FieldKey.fromString("lastVetReview"),
                FieldKey.fromString("Id/assignedVet/assignedVet")
        ));

        TableSelector ts = new TableSelector(ti, cols.values(), new SimpleFilter(FieldKey.fromString("earliestRemarkSinceReview"), "-" + duration + "d", CompareType.DATE_LTE), new Sort("Id"));

        final List<String> rows = new ArrayList<>();
        final String urlBase = getExecuteQueryUrl(c, "study", "demographics", "Vet Review") + "&query.Id~eq=";
                ts.forEach(new Selector.ForEachBlock<ResultSet>()
        {
            @Override
            public void exec(ResultSet object) throws SQLException
            {
                Results rs = new ResultsImpl(object, cols);

                rows.add("<tr><td>" +
                        "<a href='" + urlBase + rs.getString(FieldKey.fromString("Id")) + "'>" + rs.getString(FieldKey.fromString("Id")) + "</a></td>" +
                        "<td>" + (rs.getString(FieldKey.fromString("Id/assignedVet/assignedVet")) == null ? "NONE" : rs.getString(FieldKey.fromString("Id/assignedVet/assignedVet"))) + "</td>" +
                        "<td>" + _dateFormat.format(rs.getDate(FieldKey.fromString("earliestRemarkSinceReview"))) + "</td>" +
                        "<td>" + (rs.getDate(FieldKey.fromString("lastVetReview")) == null ? "Never" : _dateFormat.format(rs.getDate(FieldKey.fromString("lastVetReview")))) + "</td>" +
                        "<td>" + rs.getString(FieldKey.fromString("calculated_status")) + "</td>" +
                        "</tr>");
            }
        });

        if (!rows.isEmpty())
        {
            msg.append("<b>ALERT: There are " + rows.size() + " animals that have remarks entered at least " + duration + " days ago, but have not yet been reviewed.</b><br>\n");
            msg.append("<table border=1 style='border-collapse: collapse;'><tr><td>Id</td><td>Assigned Vet</td><td>Oldest Remark Needing Review</td><td>Last Vet Review</td><td>Status</td></tr>");
            for (String row : rows)
            {
                msg.append(row);
            }

            msg.append("</table><hr>\n\n");
        }
    }

    protected void animalsWithoutAssignedVet(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("calculated_status"), "Alive");
        filter.addCondition(FieldKey.fromString("Id/assignedVet/assignedVet"), null, CompareType.ISBLANK);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("demographics"), filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " living animals that do not currently have an assigned vet.  Vet assignment is controlled by open cases, project assignment and housing.  This likely means the table governing which vets are assigned to the various locations/projects needs to be updated.</b><br>\n");

            msg.append("<p><a href='" + getExecuteQueryUrl(c, "study", "demographics", "By Location", filter) + "'>Click here to view the list of animals without an assigned vet</a></p>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "vet_assignment_summary", null) + "'>Click here to view or update the rules governing vet assignment</a></p>\n");
            msg.append("<hr>\n");
        }
    }
}
