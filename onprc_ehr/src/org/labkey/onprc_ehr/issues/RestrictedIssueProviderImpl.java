package org.labkey.onprc_ehr.issues;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.issues.Issue;
import org.labkey.api.issues.RestrictedIssueProvider;
import org.labkey.api.security.Group;
import org.labkey.api.security.User;
import org.labkey.api.security.ValidEmail;
import org.labkey.api.util.Pair;

import java.util.List;
import java.util.Objects;

public class RestrictedIssueProviderImpl implements RestrictedIssueProvider
{
    @Override
    public boolean hasPermission(Container c, User user, @NotNull Issue issue, @Nullable Group groupWithAccess)
    {
        // Site admins always have access
        if (user.isInSiteAdminGroup())
            return true;

        // Assigned to users have access
        if (Objects.equals(issue.getAssignedTo(), user.getUserId()))
            return true;

        // anyone on the notify list
        List<Pair<User, ValidEmail>> notifyUsers = issue.getNotifyListUserEmail();
        for (Pair<User, ValidEmail> nu : notifyUsers)
        {
            if (user.equals(nu.getKey()))
                return true;
        }

        // if there is an option group configured, members will have access
        if (groupWithAccess != null)
        {
            return user.isInGroup(groupWithAccess.getUserId());
        }
        return false;
    }
}
