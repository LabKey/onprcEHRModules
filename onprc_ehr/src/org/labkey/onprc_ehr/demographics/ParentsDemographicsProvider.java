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
public class ParentsDemographicsProvider extends AbstractListDemographicsProvider
{
    public ParentsDemographicsProvider()
    {
        super("parentageSummary", "parents");
    }

    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("parent"));
        keys.add(FieldKey.fromString("relationship"));
        keys.add(FieldKey.fromString("method"));

        return keys;
    }
}
