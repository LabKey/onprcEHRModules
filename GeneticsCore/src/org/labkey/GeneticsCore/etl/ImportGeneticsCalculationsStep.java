package org.labkey.GeneticsCore.etl;

import org.apache.commons.lang3.StringUtils;
import org.apache.xmlbeans.XmlException;
import org.jetbrains.annotations.NotNull;
import org.labkey.GeneticsCore.GeneticsCoreModule;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.di.TaskRefTask;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.module.ModuleProperty;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.view.UnauthorizedException;
import org.labkey.api.writer.ContainerUser;

import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class ImportGeneticsCalculationsStep implements TaskRefTask
{
    protected ContainerUser _containerUser;

    @Override
    public RecordedActionSet run(@NotNull PipelineJob job) throws PipelineJobException
    {
        Module ehr = ModuleLoader.getInstance().getModule("ehr");
        Module geneticsCore = ModuleLoader.getInstance().getModule(GeneticsCoreModule.class);

        ModuleProperty mp = ehr.getModuleProperties().get("EHRStudyContainer");
        String ehrContainerPath = StringUtils.trimToNull(mp.getEffectiveValue(_containerUser.getContainer()));
        if (ehrContainerPath == null)
        {
            throw new PipelineJobException("EHRStudyContainer has not been set");
        }

        Container ehrContainer = ContainerManager.getForPath(ehrContainerPath);
        if (ehrContainer == null)
        {
            throw new PipelineJobException("Invalid container: " + ehrContainerPath);
        }

        if (!_containerUser.getContainer().equals(ehrContainer))
        {
            throw new PipelineJobException("This ETL can only be run from the EHRStudyContainer");
        }

        // Downstream import events will get additional permissions checks
        if (!ehrContainer.hasPermission(_containerUser.getUser(), UpdatePermission.class))
        {
            throw new UnauthorizedException();
        }

        ModuleProperty mp2 = geneticsCore.getModuleProperties().get("KinshipDataPath");
        String pipeDirPath = StringUtils.trimToNull(mp2.getEffectiveValue(ehrContainer));
        if (pipeDirPath == null)
        {
            throw new PipelineJobException("Must provide the filepath to import data using the KinshipDataPath module property");
        }

        File pipeDir = new File(pipeDirPath);
        if (!pipeDir.exists())
        {
            throw new PipelineJobException("Path does not exist: " + pipeDir.getPath());
        }

        File kinship = new File(pipeDir, "kinship.txt");
        if (!kinship.exists())
        {
            throw new PipelineJobException("File does not exist: " + kinship.getPath());
        }

        File inbreeding = new File(pipeDir, "inbreeding.txt");
        if (!inbreeding.exists())
        {
            throw new PipelineJobException("File does not exist: " + inbreeding.getPath());
        }

        EHRService.get().standaloneProcessKinshipAndInbreeding(ehrContainer, _containerUser.getUser(), pipeDir, job.getLogger());

        return new RecordedActionSet();
    }

    @Override
    public List<String> getRequiredSettings()
    {
        return Collections.emptyList();
    }

    @Override
    public void setSettings(Map<String, String> settings) throws XmlException
    {

    }

    @Override
    public void setContainerUser(ContainerUser containerUser)
    {
        _containerUser = containerUser;
    }
}
