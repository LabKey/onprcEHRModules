package org.labkey.GeneticsCore;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.labkey.GeneticsCore.mhc.MhcTaskRef;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.ConfirmAction;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.di.DataIntegrationService;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.util.HtmlString;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.HtmlView;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

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

    @RequiresPermission(AdminPermission.class)
    public class ResetMhcAggregateTimeAction extends ConfirmAction<Object>
    {
        @Override
        public ModelAndView getConfirmView(Object o, BindException errors) throws Exception
        {
            setTitle("Reset MHC Aggregation Pipeline Time");

            return new HtmlView(HtmlString.of("This will reset the last run time for the MHC aggregation pipeline job, causing it to re-process all IDs. Do you want to continue?"));
        }

        @Override
        public boolean handlePost(Object o, BindException errors) throws Exception
        {
            MhcTaskRef.saveLastRun(getContainer(), null);

            return true;
        }

        @Override
        public void validateCommand(Object o, Errors errors)
        {

        }

        @NotNull
        @Override
        public URLHelper getSuccessURL(Object o)
        {
            return getContainer().getStartURL(getUser());
        }
    }


    @RequiresPermission(UpdatePermission.class)
    public static class ImportGeneticsDataAction extends MutatingApiAction<Object>
    {
        @Override
        public ApiResponse execute(Object form, BindException errors)
        {
            try
            {
                DataIntegrationService.get().runTransformNow(getContainer(), getUser(), "{GeneticsCore}/KinshipDataImport");

                return new ApiSimpleResponse("success", true);
            }
            catch (Exception e)
            {
                _log.error("Unable to initiate genetics data import", e);
                errors.reject(ERROR_MSG, "Unable to initiate genetics data import");
                return null;
            }
        }
    }
}
