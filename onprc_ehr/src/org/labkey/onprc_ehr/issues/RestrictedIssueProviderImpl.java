package org.labkey.onprc_ehr.issues;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.PropertyManager;
import org.labkey.api.issues.Issue;
import org.labkey.api.issues.RestrictedIssueProvider;
import org.labkey.api.query.SimpleValidationError;
import org.labkey.api.query.ValidationError;
import org.labkey.api.security.Group;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.User;
import org.labkey.api.security.ValidEmail;
import org.labkey.api.util.Pair;

import java.util.List;
import java.util.Objects;

public class RestrictedIssueProviderImpl implements RestrictedIssueProvider
{
    private static final String CAT_RESTRICTED_ISSUE_DEF_PROPERTIES = "RestrictedIssueDefProperties-";
    private static final String PROP_RESTRICTED_ISSUE_LIST = "issueRestrictedIssueList";
    private static final String PROP_RESTRICTED_ISSUE_LIST_GROUP = "issueRestrictedIssueListGroup";

    @Override
    public void setRestrictedIssueTracker(Container c, String issueDefName, Boolean isRestricted)
    {
        setPropertyValue(c, issueDefName, PROP_RESTRICTED_ISSUE_LIST, String.valueOf(isRestricted));
    }

    @Override
    public boolean isRestrictedIssueTracker(Container c, String issueDefName)
    {
        String value = getPropertyValue(c, issueDefName, PROP_RESTRICTED_ISSUE_LIST);
        if (value != null)
        {
            return Boolean.parseBoolean(value);
        }
        return false;
    }

    @Override
    public void setRestrictedIssueListGroup(Container c, String issueDefName, @Nullable Group group)
    {
        setPropertyValue(c, issueDefName, PROP_RESTRICTED_ISSUE_LIST_GROUP, null != group ? String.valueOf(group.getUserId()) : "0");
    }

    @Override
    public @Nullable Group getRestrictedIssueListGroup(Container c, String issueDefName)
    {
        String groupId = getPropertyValue(c, issueDefName, PROP_RESTRICTED_ISSUE_LIST_GROUP);
        if (null == groupId)
            return null;

        return SecurityManager.getGroup(Integer.valueOf(groupId));
    }

    private void setPropertyValue(Container c, String issueDefName, String key, String value)
    {
        PropertyManager.PropertyMap props = PropertyManager.getWritableProperties(c, getPropMapName(issueDefName), true);
        props.put(key, value);
        props.save();
    }

    private String getPropertyValue(Container c, String issueDefName, String key)
    {
        return PropertyManager.getProperties(c, getPropMapName(issueDefName)).get(key);
    }

    private String getPropMapName(String issueDefName)
    {
        if (issueDefName == null)
            throw new IllegalArgumentException("Issue def name must be specified");

        return CAT_RESTRICTED_ISSUE_DEF_PROPERTIES + issueDefName;
    }

    @Override
    public boolean hasPermission(User user, @NotNull Issue issue, List<Issue> relatedIssues, List<ValidationError> errors)
    {
        // Site admins always have access
        if (user.isInSiteAdminGroup())
            return true;

        Container issueContainer = ContainerManager.getForId(issue.getContainerId());
        if (issueContainer != null && isRestrictedIssueTracker(issueContainer, issue.getIssueDefName()))
        {
            Group group = getRestrictedIssueListGroup(issueContainer, issue.getIssueDefName());
            if (!checkAccess(user, issue, group))
            {
                errors.add(new SimpleValidationError("This issue is in a restricted issue list. You do not have access to this issue"));
                return false;
            }
        }

        // the user must also have access to all related issues
        for (Issue related : relatedIssues)
        {
            Container relatedContainer = ContainerManager.getForId(related.getContainerId());
            if (relatedContainer != null && isRestrictedIssueTracker(relatedContainer, related.getIssueDefName()))
            {
                Group relatedGroup = getRestrictedIssueListGroup(relatedContainer, related.getIssueDefName());
                if (!checkAccess(user, related, relatedGroup))
                {
                    errors.add(new SimpleValidationError(String.format("A related issue : %d is in a restricted issue list. You do not have access to that issue", related.getIssueId())));
                    return false;
                }
            }
        }
        return true;
    }

    private boolean checkAccess(User user, @NotNull Issue issue, @Nullable Group groupWithAccess)
    {
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
