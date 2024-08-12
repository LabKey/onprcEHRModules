/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * Author: Kolli
 * Date: 1/13/2021
 * Time: 10:36 AM
 * ART Core Billing service request form
 */
package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.RequestFormSection;
import org.labkey.api.module.Module;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.onprc_ehr.security.ONPRC_EHRServiceRequestsPermission;

import java.util.Arrays;

//Created: 1/13/2021 Kollil
public class ARTCoreRequestFormType extends RequestForm
{
    public static final String NAME = "ART CORE SERVICES REQUEST";
    public static final String DEFAULT_GROUP = "ART Core Services";

    public ARTCoreRequestFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, NAME, "Requests", Arrays.asList(
                new RequestFormSection(),
                //new RequestInstructionsFormSection(),
                new AnimalDetailsFormSection(),
                new ClinicalEncountersFormSection()
//                new ARTCore_OtherServices_FormSection()
        ));

        addClientDependency(ClientDependency.supplierFromPath("onprc_ehr/model/sources/ARTCore_Services.js"));

        for (FormSection s : getFormSections())
        {
            s.addConfigSource("ARTCore_Services");
        }
    }

    //    Added: 8-12-2024  R.Blasa
    @Override
    protected boolean canInsert()
    {
        if (!getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_EHRServiceRequestsPermission.class))

            return false;

        return super.canInsert();
    }


}