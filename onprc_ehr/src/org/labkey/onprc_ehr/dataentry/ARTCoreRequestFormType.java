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
import org.labkey.api.security.Group;
import org.labkey.api.security.GroupManager;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.security.xml.GroupEnumType;

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
//    //Added: 8-7-2024 R.Blasa
//    @Override
//    public boolean isVisible()
//    {
//        Group g = GroupManager.getGroup(getCtx().getContainer(), "Death Entry", GroupEnumType.SITE);
//        if (g != null && getCtx().getUser().isInGroup(g.getUserId()) && !getCtx().getContainer().hasPermission(getCtx().getUser(), AdminPermission.class))
//        {
//            return false;
//        }
//        return super.isVisible();
//    }

}