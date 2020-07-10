package org.labkey.GeneticsCore;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.labkey.api.action.SpringActionController;

/**
 * User: bimber
 * Date: 7/1/13
 * Time: 11:59 AM
 */
public class GeneticsCoreController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(GeneticsCoreController.class);
    private static final Logger _log = LogManager.getLogger(GeneticsCoreController.class);

    public GeneticsCoreController()
    {
        setActionResolver(_actionResolver);
    }
}
