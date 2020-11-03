package org.labkey.onprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * Created by bimber on 3/23/2017.
 */
public class GeneticAncestryDemographicsProvider extends AbstractDemographicsProvider
{
    public GeneticAncestryDemographicsProvider(Module module)
    {
        super(module, "study", "demographicsGeneticAncestry");
        _supportsQCState = false;
    }

    @Override
    public String getName()
    {
        return "Genetic Ancestry";
    }

    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("geneticAncestry"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return "study".equalsIgnoreCase(schema) && ("geneticAncestry".equalsIgnoreCase(query) || "Genetic Ancestry".equalsIgnoreCase(query));
    }
}
