/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.form.field.SimpleCheckCombo', {
    extend: 'Ext.ux.CheckCombo',
    alias: 'widget.onprc_ehr-simplecheckcombo',

    initComponent: function(){
        Ext4.apply(this, {
            triggerAction: 'all',
            queryMode: 'local',
            typeAhead: true,
            store: {
                type: 'labkey-store',
                containerPath: this.containerPath,
                schemaName: this.schemaName,
                queryName: this.queryName,
                viewName: this.viewName,
                columns: this.columns,
                sort: this.sortFields || null,
                filterArray: this.filterArray,
                autoLoad: true
            }
        });

        this.callParent();
    }
});