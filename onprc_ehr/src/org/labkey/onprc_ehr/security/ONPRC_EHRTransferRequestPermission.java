/*
 * Copyright (c) 2014 LabKey Corporation
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
package org.labkey.onprc_ehr.security;

import org.labkey.api.ehr.security.AbstractEHRPermission;

/**
 * Created by bimber on 10/9/2014.
 */
public class ONPRC_EHRTransferRequestPermission extends AbstractEHRPermission
{
    public ONPRC_EHRTransferRequestPermission()
    {
        super("ONPRCEHRTransferRequestPermission", "This is the base permission used to grant permission to enter requests for hosuing transfers");
    }
}
