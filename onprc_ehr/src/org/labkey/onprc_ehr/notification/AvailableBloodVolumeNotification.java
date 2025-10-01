package org.labkey.onprc_ehr.notification;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.security.User;

import java.util.Date;


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
    /* From Hugh Crank:
     * Server mkt7: Runs at :55 from 4:55am to 7:55pm
     * Server mkt8: Runs at :25 from 4:25am to 7:25pm
     */
    @Override
    public String getCronString()
    {
        return "0 15 6-19 * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "15 minutes after every hour between 06:15 and 19:15.";
    }

    @Override
    public String getDescription()
    {
        return "Sends an alert on status of Available Blood Volume data from Mathematica.";
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
            msg.append("<b>The available blood volume data from Mathematica is stale.</b><br>\n");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "ValidateAvailableBloodProcess", null) + "'>Click here to view labkeyPublic.AvailableBloodVolume.</a><br>\n\n");
            msg.append("</p><br><hr>");
        }
        else
        {
            msg.append("The available blood volume data from Mathematica is current.<br><hr>");
            msg.append("<p><a href='" + getExecuteQueryUrl(c, "onprc_ehr", "ValidateAvailableBloodProcess", null) + "'>Click here to view labkeyPublic.AvailableBloodVolume.</a><br>\n\n");
            msg.append("</p><br><hr>");
        }
    }}
