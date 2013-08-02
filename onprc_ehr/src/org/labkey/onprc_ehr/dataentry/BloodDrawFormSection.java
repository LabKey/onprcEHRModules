package org.labkey.onprc_ehr.dataentry;

import org.labkey.api.ehr.dataentry.SimpleFormSection;

import java.util.Collections;

/**
 * User: bimber
 * Date: 7/7/13
 * Time: 10:36 AM
 */
public class BloodDrawFormSection extends SimpleGridPanel
{
    public BloodDrawFormSection()
    {
        super("study", "Blood Draws", "Blood Draws");
        setClientStoreClass("EHR.data.BloodDrawClientStore");
    }
}
