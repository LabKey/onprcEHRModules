package org.labkey.GeneticsCore;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.action.ConfirmAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.pipeline.PipeRoot;
import org.labkey.api.pipeline.PipelineService;
import org.labkey.api.pipeline.PipelineUrls;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.util.HtmlString;
import org.labkey.api.util.PageFlowUtil;
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
    public class AggregateMhcAction extends ConfirmAction<AggregateMhcForm>
    {
        @Override
        public ModelAndView getConfirmView(AggregateMhcForm o, BindException errors) throws Exception
        {
            setTitle("Sync MHC Data from PRIMe");

            StringBuilder sb = new StringBuilder();
            sb.append("This will aggregate MHC typing data into the mhc_data table, creating a single dataset with one row per animal/marker. Do you want to continue?");
            sb.append("<br><br><label>Check this box to reset the last run time: </label> <input type='checkbox' name = 'resetLastRun' />");

            return new HtmlView(HtmlString.unsafe(sb.toString()));
        }

        @Override
        public boolean handlePost(AggregateMhcForm o, BindException errors) throws Exception
        {
            try
            {
                if (o.isResetLastRun())
                {
                    MhcAggregationPipelineJob.saveLastRun(getContainer(), null);
                }

                PipeRoot pipelineRoot = PipelineService.get().findPipelineRoot(getContainer());
                MhcAggregationPipelineJob job = new MhcAggregationPipelineJob(getContainer(), getUser(), getViewContext().getActionURL(), pipelineRoot);
                PipelineService.get().queueJob(job);
            }
            catch (Exception e)
            {
                _log.error(e);
                errors.reject(ERROR_MSG, e.getMessage());
                return false;

            }

            return true;
        }

        @Override
        public void validateCommand(AggregateMhcForm o, Errors errors)
        {

        }

        @NotNull
        @Override
        public URLHelper getSuccessURL(AggregateMhcForm o)
        {
            return PageFlowUtil.urlProvider(PipelineUrls.class).urlBegin(getContainer());
        }
    }

    public static class AggregateMhcForm
    {
        private boolean resetLastRun = false;

        public boolean isResetLastRun()
        {
            return resetLastRun;
        }

        public void setResetLastRun(boolean resetLastRun)
        {
            this.resetLastRun = resetLastRun;
        }
    }
}
