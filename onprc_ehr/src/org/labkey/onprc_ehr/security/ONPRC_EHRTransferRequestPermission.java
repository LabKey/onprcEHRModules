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
