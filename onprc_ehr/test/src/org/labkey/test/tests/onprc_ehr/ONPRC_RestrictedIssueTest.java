/*
 * Copyright (c) 2025-2026 LabKey Corporation
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
package org.labkey.test.tests.onprc_ehr;

import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.ONPRC;
import org.labkey.test.pages.issues.DetailsPage;
import org.labkey.test.pages.issues.InsertPage;
import org.labkey.test.pages.issues.UpdatePage;
import org.labkey.test.pages.search.SearchResultsPage;
import org.labkey.test.util.IssuesHelper;
import org.labkey.test.util.SearchHelper;
import org.labkey.test.util.TestUser;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.labkey.test.util.PermissionsHelper.EDITOR_ROLE;
import static org.labkey.test.util.PermissionsHelper.FOLDER_ADMIN_ROLE;

@Category({EHR.class, ONPRC.class})
public class ONPRC_RestrictedIssueTest extends BaseWebDriverTest
{
    private final IssuesHelper _issuesHelper;

    // constants
    private static final TestUser USER1 = new TestUser("user1_issuetest@issues.test");
    private static final TestUser USER2 = new TestUser("user2_issuetest@issues.test");
    private static final TestUser ISSUE_CREATOR = new TestUser("issue_creator_issuetest@issues.test");
    private static final TestUser FOLDER_ADMIN = new TestUser("folder_admin_issuetest@issues.test");

    private static final String RESTRICTED_ISSUES_LIST = "restricted-issues";
    private static final String UNRESTRICTED_ISSUES_LIST = "unrestricted-issues";
    private static final String ACCESS_ERROR_MSG = "This issue is in a restricted issue list. You do not have access to this issue";

    public ONPRC_RestrictedIssueTest()
    {
        _issuesHelper = new IssuesHelper(this);
    }

    @BeforeClass
    public static void doSetup()
    {
        ONPRC_RestrictedIssueTest initTest = getCurrentTest();
        initTest.doInit();
    }

    public void doInit()
    {
        _containerHelper.createProject(getProjectName(), null);

        // Create test users
        USER1.create(this).addPermission(EDITOR_ROLE, getProjectName());
        USER2.create(this).addPermission(EDITOR_ROLE, getProjectName());
        ISSUE_CREATOR.create(this).addPermission(EDITOR_ROLE, getProjectName());
        FOLDER_ADMIN.create(this).addPermission(FOLDER_ADMIN_ROLE, getProjectName());

        // Add issue list definitions
        _issuesHelper.createNewIssuesList(RESTRICTED_ISSUES_LIST, _containerHelper, true, false, false);
        waitAndClickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        _issuesHelper.goToAdmin();
        _issuesHelper.setRestrictedIssueList(true);
        _issuesHelper.setIssueAssignmentList("Site: Users");
        clickButton("Save");

        goToProjectHome();
        _issuesHelper.createNewIssuesList(UNRESTRICTED_ISSUES_LIST, _containerHelper, false, false, false);
        waitAndClickAndWait(Locator.linkContainingText(UNRESTRICTED_ISSUES_LIST));
        _issuesHelper.goToAdmin();
        _issuesHelper.setIssueAssignmentList("Site: Users");
        clickButton("Save");
    }

    @Override
    protected void doCleanup(boolean afterTest) throws TestTimeoutException
    {
        _userHelper.deleteUsers(false, USER1, USER2, ISSUE_CREATOR, FOLDER_ADMIN);
        _containerHelper.deleteProject(getProjectName(), afterTest);
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("ehr", "onprc_ehr");
    }

    @Override
    protected String getProjectName()
    {
        return "RestrictedIssuesVerifyProject";
    }

    @Test
    public void restrictedIssueTest()
    {
        goToProjectHome();

        // create a few issues in the restricted list
        impersonate(ISSUE_CREATOR.getEmail());
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        DetailsPage detailsPage = _issuesHelper.addIssue(String.format("Restricted issue assigned to (%s)", USER1.getUserDisplayName()), USER1.getUserDisplayName());
        final String ISSUE_1 = detailsPage.getIssueId();
        InsertPage insertPage = detailsPage.clickCreateNewIssue();
        insertPage.title().set(String.format("Restricted issue assigned to (%s)", USER2.getUserDisplayName()));
        insertPage.assignedTo().set(USER2.getUserDisplayName());
        insertPage.save();
        final String ISSUE_2 = insertPage.getIssueId();
        stopImpersonating();

        // verify site admins can see both issues (but not folder admins)
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyIssueAccess(ISSUE_1, true);
        verifyIssueAccess(ISSUE_2, true);

        impersonate(FOLDER_ADMIN.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyIssueAccess(ISSUE_1, false);
        verifyIssueAccess(ISSUE_2, false);
        stopImpersonating();

        // creators can see all of the issues they opened
        impersonate(ISSUE_CREATOR.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyIssueAccess(ISSUE_1, true);
        verifyIssueAccess(ISSUE_2, true);
        stopImpersonating();

        // users can view issues assigned to them
        impersonate(USER1.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyIssueAccess(ISSUE_1, true);
        verifyIssueAccess(ISSUE_2, false);
        stopImpersonating();

        // verify notify list grants access
        UpdatePage page = UpdatePage.beginAt(this, ISSUE_2);
        page.notifyList().set(USER1.getEmail());
        page.save();
        impersonate(USER1.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyIssueAccess(ISSUE_1, true);
        verifyIssueAccess(ISSUE_2, true);
        stopImpersonating();
    }

    private void verifyIssueAccess(String issueID, boolean shouldHaveAccess)
    {
        Locator issueLink = getIssueLinkLocator(issueID);
        waitForElement(issueLink, defaultWaitForPage);
        pushLocation();
        waitAndClickAndWait(issueLink);
        if (shouldHaveAccess)
            assertTextNotPresent(ACCESS_ERROR_MSG);
        else
            assertTextPresent(ACCESS_ERROR_MSG);
        popLocation();
    }

    @Test
    public void relatedIssueTest()
    {
        goToProjectHome();

        // create 2 issues related to each other
        impersonate(ISSUE_CREATOR.getEmail());
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        DetailsPage detailsPage = _issuesHelper.addIssue(String.format("Restricted issue assigned to (%s)", USER1.getUserDisplayName()), USER1.getUserDisplayName());
        final String ISSUE_1 = detailsPage.getIssueId();
        InsertPage insertPage = detailsPage.clickCreateNewIssue();
        insertPage.title().set(String.format("Restricted issue assigned to (%s)", USER2.getUserDisplayName()));
        insertPage.assignedTo().set(USER2.getUserDisplayName());
        insertPage.related().set(ISSUE_1);
        insertPage.save();
        final String ISSUE_2 = insertPage.getIssueId();
        stopImpersonating();

        // verify creator sees both all issues and their relationships
        impersonate(ISSUE_CREATOR.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyRelatedIssueAccess(ISSUE_1, ISSUE_2, true);
        verifyRelatedIssueAccess(ISSUE_2, ISSUE_1, true);
        stopImpersonating();

        // verify users can open issue assigned to them but not see the related issue
        impersonate(USER1.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyRelatedIssueAccess(ISSUE_1, ISSUE_2, false);
        // shouldn't be able to access the other issue at all
        verifyIssueAccess(ISSUE_2, false);
        stopImpersonating();

        impersonate(USER2.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        verifyRelatedIssueAccess(ISSUE_2, ISSUE_1, false);
        verifyIssueAccess(ISSUE_1, false);
        stopImpersonating();

        // create issues in the unrestricted issue list and relate them to issues in the other list
        impersonate(ISSUE_CREATOR.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(UNRESTRICTED_ISSUES_LIST));
        // issue related to both restricted issues
        detailsPage = _issuesHelper.addIssue(String.format("UnRestricted issue assigned to (%s)", USER1.getUserDisplayName()),
                USER1.getUserDisplayName(), Collections.singletonMap("related", String.join(",", List.of(ISSUE_1, ISSUE_2))));
        final String ISSUE_3 = detailsPage.getIssueId();
        stopImpersonating();

        // any user with read access to the unrestricted list can see details but no links to the linked restricted issues
        impersonate(FOLDER_ADMIN.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(UNRESTRICTED_ISSUES_LIST));
        verifyRelatedIssueAccess(ISSUE_3, ISSUE_1, false);
        verifyRelatedIssueAccess(ISSUE_3, ISSUE_2, false);
        stopImpersonating();

        // users can link to the restricted issues they have access to
        impersonate(USER1.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(UNRESTRICTED_ISSUES_LIST));
        verifyRelatedIssueAccess(ISSUE_3, ISSUE_1, true);
        verifyRelatedIssueAccess(ISSUE_3, ISSUE_2, false);
        stopImpersonating();

        impersonate(USER2.getEmail());
        goToProjectHome();
        clickAndWait(Locator.linkContainingText(UNRESTRICTED_ISSUES_LIST));
        verifyRelatedIssueAccess(ISSUE_3, ISSUE_1, false);
        verifyRelatedIssueAccess(ISSUE_3, ISSUE_2, true);
        stopImpersonating();
    }

    private void verifyRelatedIssueAccess(String issueID, String relatedIssueID, boolean shouldHaveRelatedAccess)
    {
        Locator issueLink = getIssueLinkLocator(issueID);
        waitForElement(issueLink, defaultWaitForPage);
        pushLocation();
        clickAndWait(issueLink);
        Locator relatedIssueLink = getIssueLinkLocator(relatedIssueID);
        if (shouldHaveRelatedAccess)
        {
            assertElementPresent(relatedIssueLink);
            // related link should also navigate properly
            clickAndWait(relatedIssueLink);
            assertTextNotPresent(ACCESS_ERROR_MSG);
        }
        else
        {
            // no link but the related ID should render as text
            assertElementNotPresent(relatedIssueLink);
            assertTextPresent(relatedIssueID);
        }
        popLocation();
    }

    private Locator getIssueLinkLocator(String issueID)
    {
        return Locator.tagWithAttributeContaining("a", "href", String.format("issues-details.view?issueId=%s", issueID));
    }

    @Test
    public void restrictedIssueSearchTest()
    {
        goToProjectHome();

        // create a few issues in the restricted list
        clickAndWait(Locator.linkContainingText(RESTRICTED_ISSUES_LIST));
        DetailsPage detailsPage = _issuesHelper.addIssue("Restricted issue search test #1", USER1.getUserDisplayName());
        final String ISSUE_1 = detailsPage.getIssueId();
        InsertPage insertPage = detailsPage.clickCreateNewIssue();
        insertPage.title().set("Restricted issue search test #2");
        insertPage.assignedTo().set(USER2.getUserDisplayName());
        detailsPage = insertPage.save();
        final String ISSUE_2 = detailsPage.getIssueId();

        SearchHelper searchHelper = new SearchHelper(this);
        SearchResultsPage resultsPage = searchHelper.searchFor("\"Restricted issue search test\"");

        // verify that we can return links even if the user doesn't have permission to view a restricted issue
        Assert.assertEquals("Number of search results not expected", 2, resultsPage.getResults().size());

        // verify assigned to users will see both results but shouldn't be able to see details of issues not assigned to them,
        // also verify that there is a warning rendered if a search result is restricted
        impersonate(USER1.getEmail());
        assertTextPresent("Restricted Issue: You do not have access. Contact your administrator for access.");
        verifyIssueAccess(ISSUE_1, true);
        verifyIssueAccess(ISSUE_2, false);
        stopImpersonating(false);

        impersonate(USER2.getEmail());
        assertTextPresent("Restricted Issue: You do not have access. Contact your administrator for access.");
        verifyIssueAccess(ISSUE_1, false);
        verifyIssueAccess(ISSUE_2, true);
        stopImpersonating();
    }
}
