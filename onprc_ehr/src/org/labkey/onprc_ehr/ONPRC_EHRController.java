package org.labkey.onprc_ehr;

import org.labkey.api.action.SpringActionController;

/**
 * Created by IntelliJ IDEA.
 * User: bbimber
 * Date: 5/16/12
 * Time: 1:56 PM
 */
public class ONPRC_EHRController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(ONPRC_EHRController.class);

    public ONPRC_EHRController()
    {
        setActionResolver(_actionResolver);
    }
}
