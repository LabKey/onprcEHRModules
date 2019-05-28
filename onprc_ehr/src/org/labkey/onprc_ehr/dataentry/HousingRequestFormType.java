/*
 * Copyright (c) 2014-2016 LabKey Corporation
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
package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.AnimalDetailsFormSection;
import org.labkey.api.ehr.dataentry.DataEntryFormContext;
import org.labkey.api.ehr.dataentry.FormSection;
import org.labkey.api.ehr.dataentry.RequestForm;
import org.labkey.api.ehr.dataentry.RequestFormSection;
import org.labkey.api.module.Module;
import org.labkey.onprc_ehr.security.ONPRC_EHRTransferRequestPermission;

import java.util.Arrays;

/**
 * User: bimber
 * Date: 7/29/13
 * Time: 5:03 PM
 */
public class HousingRequestFormType extends RequestForm
{
    public static final String NAME = "housing_request";

    public HousingRequestFormType(DataEntryFormContext ctx, Module owner)
    {
        super(ctx, owner, NAME, "Housing Transfer Request", "Requests", Arrays.asList(
                new RequestFormSection(),
                //new RequestInstructionsFormSection(),
                new AnimalDetailsFormSection(),
                new HousingFormSection("onprc_ehr", "housing_transfer_requests", "Requested Housing Transfers")
        ));
    }

    @Override
    protected boolean canInsert()
    {
        return getCtx().getContainer().hasPermission(getCtx().getUser(), ONPRC_EHRTransferRequestPermission.class);
    }
}
