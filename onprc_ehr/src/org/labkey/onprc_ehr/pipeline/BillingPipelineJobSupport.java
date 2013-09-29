package org.labkey.onprc_ehr.pipeline;

import java.io.File;
import java.util.Date;

/**
 * User: bimber
 * Date: 9/14/13
 * Time: 9:27 PM
 */
public interface BillingPipelineJobSupport
{
    public Date getStartDate();

    public Date getEndDate();

    public String getComment();

    public String getName();

    public boolean isTestOnly();

    public File getAnalysisDir();
}
