package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;
import org.labkey.api.util.PageFlowUtil;

import java.util.Date;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;



public class AvailableBloodVolumeNotification extends ColonyAlertsNotification
{
    public AvailableBloodVolumeNotification(Module owner)
    {
        super(owner);
    }

    @Override
    public String getName()
    {
        return "Available Blood Volume Notification";
    }

    @Override
    public String getEmailSubject(Container c)
    {
        return "Available Blood Volume Alert: " + getDateTimeFormat(c).format(new Date());
    }
    @Override
    public String getCronString()
    {
        return "0 30 7-18 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 30 Minutes after the hour between 7:30AM and 6:30PM daily";
    }

    @Override
    public String getDescription()
    {
        return "The report is designed to send am alert if the hourly available Blood Volume Transfer Fails!";
    }

    @Override
    public String getMessageBodyHTML(Container c, User u)
    {
        StringBuilder msg = new StringBuilder();

        AvailableBloodCheck(c, u, msg);

        return msg.toString();
    }
    /* jonesga 5/8/2024 labkeyPublic.labkeyPublic.ValidateAvailableBloodProcess
     */
    protected void AvailableBloodCheck(final Container c, User u, final StringBuilder msg)
    {
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("date"), new Date(), CompareType.DATE_GTE);
        TableInfo ti = QueryService.get().getUserSchema(u, c, "onprc_ehr").getTable("ValidateAvailableBloodProcess", ContainerFilter.Type.AllFolders.create(c, u));
//        ((ContainerFilterable) ti).setContainerFilter(ContainerFilter.Type.AllFolders.create(u);
        TableSelector ts = new TableSelector(ti, null, null);

        long count = ts.getRowCount();
        if (count > 0)
        {
            msg.append("<b>" + count + " Available Blood Data is Stale.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "ValidateAvailableBloodProcess", null) + "'>Click here to view them</a><br>\n\n");
            msg.append("</p><br><hr>");
        }
        else
        {
            msg.append("<b>Excellent: Available Blood Volume is Current !</b><br><hr>");
        }
    }}