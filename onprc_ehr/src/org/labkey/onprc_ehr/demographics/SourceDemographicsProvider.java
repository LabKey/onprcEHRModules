package org.labkey.onprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractDemographicsProvider;
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
public class SourceDemographicsProvider extends AbstractListDemographicsProvider
{
    public SourceDemographicsProvider()
    {
        super("demographicsSource", "source");
    }

    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("fromCenter"));
        keys.add(FieldKey.fromString("source"));
        keys.add(FieldKey.fromString("type"));
        keys.add(FieldKey.fromString("source/meaning"));

        return keys;
    }
}
