package org.labkey.onprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * User: bimber
 * Date: 7/9/13
 * Time: 10:12 PM
 */
public class CagematesDemographicsProvider extends AbstractListDemographicsProvider
{
    public CagematesDemographicsProvider()
    {
        super("demographicsPaired", "cagemates");
    }

    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("total"));
        keys.add(FieldKey.fromString("animals"));

        return keys;
    }
}
