package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;

import java.util.Date;

/**
 * Created with IntelliJ IDEA.
 * User: bimber
 * Date: 4/26/13
 * Time: 9:09 AM
 */
public class TMBNotification extends ColonyAlertsNotification
{
    @Override
    public String getName()
    {
        return "TMB Notification";
    }

    @Override
    public String getEmailSubject()
    {
        return "TMB Alerts: " + _dateTimeFormat.format(new Date());
    }

    @Override
    public String getCronString()
    {
        return "0 15 5 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 5:15AM";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to provide a daily summary of TMB and Reproductive Management alerts";
    }

    public String getMessage(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        matings30DaysAgo(c, u, msg);
        offspringOver250WithMother(c, u, msg);
        pregnantAnimals(c, u, msg);

        return msg.toString();
    }

    protected void matings30DaysAgo(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("daysElapsed"), 30, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("daysElapsed"), 36, CompareType.LTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("Matings"), Table.ALL_COLUMNS, filter, null);
        if (ts.getRowCount() > 0)
        {
            msg.append("<b>WARNING: There are " + ts.getRowCount() + " matings that occurred 30-36 days ago</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=Matings&query.viewName=30-36 Days Ago'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void offspringOver250WithMother(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("ageInDays"), 250, CompareType.GTE);
        filter.addCondition(FieldKey.fromString("room/housingType/value"), "Cage Location", CompareType.EQUAL);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("offspringWithMother"), Table.ALL_COLUMNS, filter, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>WARNING: There are " + count + " offspring over 250 days old that are still in cage with their mother</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=offspringWithMother&query.viewName=Offspring Over 250 Days'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }

    protected void pregnantAnimals(final Container c, User u, final StringBuilder msg)
    {
        //SimpleFilter filter = new SimpleFilter(FieldKey.fromString("estDeliveryDays"), 30, CompareType.LTE);
        TableSelector ts = new TableSelector(getStudySchema(c, u).getTable("pregnantAnimals"), Table.ALL_COLUMNS, null, null);
        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>Alert: There are " + count + " animals known to be pregnant.</b><br>\n");
            msg.append("<p><a href='" + getBaseUrl(c) + "schemaName=study&query.queryName=pregnantAnimals'>Click here to view them</a><br>\n\n");
            msg.append("<hr>\n\n");
        }
    }
}
