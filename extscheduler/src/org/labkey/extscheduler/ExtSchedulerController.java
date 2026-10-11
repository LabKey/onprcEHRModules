/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.extscheduler;

import org.labkey.api.action.ReadOnlyApiAction;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.security.Group;
import org.labkey.api.security.MemberType;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.SecurityManager;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.ReadPermission;
import org.springframework.validation.BindException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExtSchedulerController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new SpringActionController.DefaultActionResolver(ExtSchedulerController.class);

    public ExtSchedulerController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    public static class GetSchedulerGroupMembersAction extends ReadOnlyApiAction<Object>
    {
        @Override
        public Object execute(Object o, BindException errors) throws Exception
        {
            ApiSimpleResponse response = new ApiSimpleResponse();

            String groupName = ExtSchedulerManager.getInstance().getExtSchedulerUserGroupName(getContainer());
            if (groupName == null)
            {
                response.put("success", false);
                response.put("msg", "No ExtSchedulerUserGroupName module property configured.");
                return response;
            }

            // first check for project group, then site group
            Integer groupId = SecurityManager.getGroupId(getContainer().getProject(), groupName, false);
            if (groupId == null)
                groupId = SecurityManager.getGroupId(null, groupName, false);

            if (groupId == null)
            {
                response.put("success", false);
                response.put("msg", "No security group found with the following name: " + groupName + ".");
                return response;
            }

            Group group = SecurityManager.getGroup(groupId);
            if (group == null)
            {
                response.put("success", false);
                response.put("msg", "No security group found with the following id: " + groupId + ".");
                return response;
            }
            else
            {
                List<Map<String, Object>> userProps = new ArrayList<>();
                for (User user : SecurityManager.getAllGroupMembers(group, MemberType.ACTIVE_USERS, true))
                    userProps.add(getUserProperties(getUser(), user));

                response.put("success", true);
                response.put("rows", userProps);
            }

            return response;
        }

        private Map<String, Object> getUserProperties(User currentUser, User user)
        {
            Map<String, Object> props = new HashMap<>();
            props.put("UserId", user.getUserId());
            props.put("DisplayName", user.getDisplayName(currentUser));
            props.put("FirstName", user.getFirstName());
            props.put("LastName", user.getLastName());
            return props;
        }
    }
}