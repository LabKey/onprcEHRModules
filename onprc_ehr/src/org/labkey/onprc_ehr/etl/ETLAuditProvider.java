package org.labkey.onprc_ehr.etl;

import org.labkey.api.audit.AbstractAuditTypeProvider;
import org.labkey.api.audit.AuditLogEvent;
import org.labkey.api.audit.AuditTypeEvent;
import org.labkey.api.audit.AuditTypeProvider;
import org.labkey.api.audit.query.AbstractAuditDomainKind;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.PropertyStorageSpec;
import org.labkey.api.exp.property.DomainKind;
import org.labkey.api.query.FieldKey;

import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

/**
 * User: klum
 * Date: 7/21/13
 */
public class ETLAuditProvider extends AbstractAuditTypeProvider implements AuditTypeProvider
{
    public static final String AUDIT_EVENT_TYPE = "EHRSyncAuditEvent";

    public static final String COLUMN_NAME_TYPE = "Type";
    public static final String COLUMN_NAME_EHR_ERRORS = "EhrErrors";
    public static final String COLUMN_NAME_DATASET_ERRORS = "DatasetErrors";
    public static final String COLUMN_NAME_EHR_LOOKUP_ERRORS = "EhrLookupErrors";

    @Override
    protected DomainKind getDomainKind()
    {
        return new ETLAuditDomainKind();
    }

    @Override
    public String getEventName()
    {
        return AUDIT_EVENT_TYPE;
    }

    @Override
    public String getLabel()
    {
        return "EHR ETL Events";
    }

    @Override
    public String getDescription()
    {
        return "EHR ETL Events";
    }

    @Override
    public <K extends AuditTypeEvent> K convertEvent(AuditLogEvent event)
    {
        ETLAuditEvent bean = new ETLAuditEvent();
        copyStandardFields(bean, event);

        bean.setType(event.getKey1());

        if (event.getIntKey1() != null)
            bean.setEhrErrors(event.getIntKey1());
        if (event.getIntKey2() != null)
            bean.setDatasetErrors(event.getIntKey2());
        if (event.getIntKey3() != null)
            bean.setEhrLookupErrors(event.getIntKey3());

        return (K)bean;
    }

    @Override
    public Map<FieldKey, String> legacyNameMap()
    {
        Map<FieldKey, String> legacyNames = super.legacyNameMap();
        legacyNames.put(FieldKey.fromParts("key1"), COLUMN_NAME_TYPE);
        legacyNames.put(FieldKey.fromParts("intKey1"), COLUMN_NAME_EHR_ERRORS);
        legacyNames.put(FieldKey.fromParts("intKey2"), COLUMN_NAME_DATASET_ERRORS);
        legacyNames.put(FieldKey.fromParts("intKey3"), COLUMN_NAME_EHR_LOOKUP_ERRORS);
        return legacyNames;
    }

    @Override
    public <K extends AuditTypeEvent> Class<K> getEventClass()
    {
        return (Class<K>)ETLAuditEvent.class;
    }

    public static class ETLAuditEvent extends AuditTypeEvent
    {
        private String _type;
        private int _ehrErrors;
        private int _datasetErrors;
        private int _ehrLookupErrors;

        public ETLAuditEvent()
        {
            super();
        }

        public ETLAuditEvent(String container, String comment)
        {
            super(AUDIT_EVENT_TYPE, container, comment);
        }

        public String getType()
        {
            return _type;
        }

        public void setType(String type)
        {
            _type = type;
        }

        public int getEhrErrors()
        {
            return _ehrErrors;
        }

        public void setEhrErrors(int ehrErrors)
        {
            _ehrErrors = ehrErrors;
        }

        public int getDatasetErrors()
        {
            return _datasetErrors;
        }

        public void setDatasetErrors(int datasetErrors)
        {
            _datasetErrors = datasetErrors;
        }

        public int getEhrLookupErrors()
        {
            return _ehrLookupErrors;
        }

        public void setEhrLookupErrors(int ehrLookupErrors)
        {
            _ehrLookupErrors = ehrLookupErrors;
        }
    }

    public static class ETLAuditDomainKind extends AbstractAuditDomainKind
    {
        public static final String NAME = "ETLAuditDomain";
        public static String NAMESPACE_PREFIX = "Audit-" + NAME;
        private static final Set<PropertyStorageSpec> _fields = new LinkedHashSet<>();

        static {
            _fields.add(createFieldSpec(COLUMN_NAME_TYPE, JdbcType.VARCHAR));
            _fields.add(createFieldSpec(COLUMN_NAME_EHR_ERRORS, JdbcType.INTEGER));
            _fields.add(createFieldSpec(COLUMN_NAME_DATASET_ERRORS, JdbcType.INTEGER));
            _fields.add(createFieldSpec(COLUMN_NAME_EHR_LOOKUP_ERRORS, JdbcType.INTEGER));
        }

        @Override
        protected Set<PropertyStorageSpec> getColumns()
        {
            return _fields;
        }

        @Override
        protected String getNamespacePrefix()
        {
            return NAMESPACE_PREFIX;
        }

        @Override
        public String getKindName()
        {
            return NAME;
        }
    }
}
