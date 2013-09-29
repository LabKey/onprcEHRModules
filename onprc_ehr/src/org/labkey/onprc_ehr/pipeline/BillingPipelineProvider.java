package org.labkey.onprc_ehr.pipeline;

import org.labkey.api.module.Module;
import org.labkey.api.pipeline.PipeRoot;
import org.labkey.api.pipeline.PipelineDirectory;
import org.labkey.api.pipeline.PipelineProvider;
import org.labkey.api.view.ViewContext;

import java.io.File;

/**
 * User: bimber
 * Date: 9/10/13
 * Time: 7:29 PM
 */
public class BillingPipelineProvider extends PipelineProvider
{
    public static final String NAME = "BillingPipeline";

    public BillingPipelineProvider(Module owningModule)
    {
        super(NAME, owningModule);
    }

    @Override
    public void updateFileProperties(ViewContext context, PipeRoot pr, PipelineDirectory directory, boolean includeAll)
    {

    }
}
