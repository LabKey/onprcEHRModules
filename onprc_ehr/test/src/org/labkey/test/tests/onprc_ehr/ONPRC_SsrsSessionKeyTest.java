/*
 * Copyright (c) 2026 LabKey Corporation
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

import org.json.JSONObject;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.ModulePropertyValue;
import org.labkey.test.TestTimeoutException;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.ONPRC;
import org.labkey.test.util.PasswordUtil;
import org.labkey.test.util.SimpleHttpRequest;
import org.labkey.test.util.SimpleHttpResponse;
import org.labkey.test.util.SqlserverOnlyTest;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.IOException;
import java.io.StringReader;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

/**
 * Exercises the SSRS session-key authentication path end to end, without a real SSRS server.
 * <p>
 * Real-world flow being approximated:
 * 1. A user opens the ONPRC printable reports page. ONPRC.Utils.preloadSession() POSTs to
 * onprc_ehr-getSessionId.api, which returns a session key (see ONPRC_EHRController.GetSessionIdAction).
 * 2. Clicking a report builds a URL to the SSRS server carrying that key as the "SessionId" parameter.
 * 3. SSRS, running on a separate host with no LabKey cookie, calls back to a selectRows URL, passing the
 * key as the "LabKeyTransformSessionId" query parameter. SecurityManager.getApiKey() reads it from the
 * query string and SessionApiKeyManager resolves it back to the user's session.
 * <p>
 * The only thing we fake is SSRS: the SSRSServerURL module property points back at this LabKey instance (the
 * same trick AbstractGenericONPRC_EHRTest uses), and the cookieless callback is replayed with SimpleHttpRequest
 * carrying ONLY the token on the URL (no session cookie, no Basic auth) -- exactly the SSRS condition.
 */
@Category({ONPRC.class})
public class ONPRC_SsrsSessionKeyTest extends BaseWebDriverTest implements SqlserverOnlyTest
{
    @Override
    protected String getProjectName()
    {
        return "ONPRC_SsrsSessionKeyTest Project";
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("ehr", "onprc_ehr");
    }

    @BeforeClass
    public static void setupProject()
    {
        ONPRC_SsrsSessionKeyTest init = getCurrentTest();
        init.doSetup();
    }

    private void doSetup()
    {
        _containerHelper.createProject(getProjectName(), null);
        _containerHelper.enableModules(Arrays.asList("EHR", "ONPRC_EHR"));

        // Treat this LabKey instance as the fake SSRS target (mirrors AbstractGenericONPRC_EHRTest). preloadSession()
        // does not actually need these, but setting them keeps the printable reports page behaving as in production.
        setModuleProperties(Arrays.asList(
                new ModulePropertyValue("ONPRC_EHR", "/" + getProjectName(), "SSRSServerURL", WebTestHelper.getBaseURL()),
                new ModulePropertyValue("ONPRC_EHR", "/" + getProjectName(), "SSRSReportFolder", "DummySSRSFolder")
        ));
    }

    @Override
    protected void checkQueries()
    {
        // No-op, as this minimal test isn't mocking up the full ONPRC EHR folder context needed to make query validation pass
    }

    @Test
    public void testSsrsSessionKeyAuthentication() throws IOException
    {
        // 1) Real workflow: open the printable reports page, which fires ONPRC.Utils.preloadSession()
        beginAt(WebTestHelper.buildURL("onprc_ehr", getProjectName(), "printableReports"));

        // 2) Harvest the token exactly as the SSRS link would receive it
        String sessionKey = waitFor(
                () -> (String) executeScript("return (window.ONPRC && ONPRC.Utils) ? ONPRC.Utils.sessionId : null;"),
                "ONPRC.Utils.preloadSession() never populated a session key", WAIT_FOR_JAVASCRIPT);
        assertNotNull("Session key was not preloaded", sessionKey);

        // The key must be a session key, NOT the raw JSESSIONID -- that is the whole point of the change.
        String jsessionId = getDriver().manage().getCookieNamed("JSESSIONID").getValue();
        assertNotEquals("getSessionId returned the raw JSESSIONID instead of a session key", jsessionId, sessionKey);

        String expectedEmail = PasswordUtil.getUsername();

        // 3) Simulate the SSRS callback: cookieless, no Basic auth, ONLY the token on the URL.
        // 3a) Identity check via whoami -- proves the callback authenticates as the right user.
        JSONObject whoAmI = cookielessGetJson(WebTestHelper.buildURL("login", getProjectName(), "whoami",
                Map.of("LabKeyTransformSessionId", sessionKey)));
        assertEquals("Token-authenticated callback resolved to the wrong user", expectedEmail, whoAmI.getString("email"));

        // 3b) Closest-to-real: the actual selectRows callback shape SSRS uses to fetch data. SSRS's XML data
        // source extension requests the XML response format, so do the same and validate that the payload is
        // well-formed XML containing the expected data row (the current user, filtered by email).
        SimpleHttpResponse selectRows = cookielessGet(WebTestHelper.buildURL("query", getProjectName(), "selectRows",
                Map.of("schemaName", "core", "query.queryName", "Users", "query.columns", "Email",
                        "query.Email~eq", expectedEmail, "respFormat", "xml", "LabKeyTransformSessionId", sessionKey)));
        assertEquals("selectRows callback with a valid token should succeed", 200, selectRows.getResponseCode());

        Document doc = parseXml(selectRows.getResponseBody());
        Element root = doc.getDocumentElement();
        assertEquals("Unexpected root element in selectRows XML response", "response", root.getTagName());
        Element rowsElement = (Element) root.getElementsByTagName("rows").item(0);
        assertNotNull("selectRows XML response is missing the <rows> element", rowsElement);
        NodeList rows = rowsElement.getElementsByTagName("element");
        assertTrue("selectRows XML response should contain at least one data row", rows.getLength() >= 1);
        Node email = ((Element) rows.item(0)).getElementsByTagName("Email").item(0);
        assertNotNull("Data row in selectRows XML response is missing the Email column", email);
        assertEquals("Data row in selectRows XML response should be for the current user", expectedEmail, email.getTextContent());

        // 4) Negative controls -- prove it is the token doing the work.
        // 4a) No token -> guest (empty email)
        JSONObject noToken = cookielessGetJson(WebTestHelper.buildURL("login", getProjectName(), "whoami"));
        assertEquals("A cookieless callback with no token should be guest", "guest", noToken.getString("email"));

        // 4b) Bogus token -> guest
        JSONObject bogus = cookielessGetJson(WebTestHelper.buildURL("login", getProjectName(), "whoami",
                Map.of("LabKeyTransformSessionId", "not-a-real-session-key")));
        assertFalse("A cookieless callback with a bogus token should be guest", bogus.getBoolean("success"));

        // 5) Lifecycle: after the user logs out, the session key must stop working (auto-invalidated with the session).
        signOut();
        JSONObject afterLogout = cookielessGetJson(WebTestHelper.buildURL("login", getProjectName(), "whoami",
                Map.of("LabKeyTransformSessionId", sessionKey)));
        assertFalse("A cookieless callback with a bogus token should be guest", afterLogout.getBoolean("success"));
    }

    /**
     * A request that carries ONLY the URL -- no session cookie and no Basic auth -- as SSRS would issue it.
     */
    private SimpleHttpResponse cookielessGet(String url) throws IOException
    {
        SimpleHttpRequest request = new SimpleHttpRequest(url);
        request.clearLogin();   // SimpleHttpRequest defaults to admin Basic auth; clear it to simulate SSRS
        // Deliberately do NOT copySession(getDriver()), so no JSESSIONID cookie is sent.
        return request.getResponse();
    }

    private JSONObject cookielessGetJson(String url) throws IOException
    {
        return new JSONObject(cookielessGet(url).getResponseBody());
    }

    /**
     * Parse a response body, failing the test if it is not well-formed XML.
     */
    private Document parseXml(String responseBody)
    {
        try
        {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            return factory.newDocumentBuilder().parse(new InputSource(new StringReader(responseBody)));
        }
        catch (Exception e)
        {
            throw new AssertionError("selectRows did not return well-formed XML. Body:\n" + responseBody, e);
        }
    }

    @Override
    protected void doCleanup(boolean afterTest) throws TestTimeoutException
    {
        _containerHelper.deleteProject(getProjectName(), afterTest);
    }
}
