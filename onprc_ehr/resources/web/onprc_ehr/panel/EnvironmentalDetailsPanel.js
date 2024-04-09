/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg employeeId
 * @cfg schemaName
 */
Ext4.define('onprc_ehr.panel.EnvironmentalDetailsPanel', {
    extend: 'Ext.panel.Panel',
    schemaName: 'onprc_ehr',

    initComponent: function(){

        Ext4.apply(this, {
            border: false,
            defaults: {
                border: false,
                style: 'margin-bottom: 20px;'
            },
            items: [{
              xtype: 'ldk-querypanel',
                queryConfig: {
                    title: 'Biological Indicators',
                    schemaName: this.schemaName,
                    queryName: 'Env_Biological_indicators',
                    failure: LDK.Utils.getErrorCallback()
                }
            },{
                xtype: 'ldk-querypanel',
                queryConfig: {
                    title: 'Water Testing',
                    schemaName: this.schemaName,
                    queryName: 'Env_Water',
                    failure: LDK.Utils.getErrorCallback()
                }
            },{
                xtype: 'ldk-querypanel',
                queryConfig: {
                    title: 'Contact Plate',
                    schemaName: this.schemaName,
                    queryName: 'Env_Contactplate',
                    failure: LDK.Utils.getErrorCallback()
                }
            },{
                xtype: 'ldk-querypanel',
                queryConfig: {
                    title: 'ATP Testing',
                    schemaName: this.schemaName,
                    queryName: 'Env_ATP',
                    failure: LDK.Utils.getErrorCallback()
                }
            }]
        });

        this.callParent();
    }
});