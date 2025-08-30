
/*
 * Copyright (c) 2013-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * This field is used to display EHR projects.  It contains a custom template for the combo list which displays both the project and protocol.
 * It also listens for participantchange events and will display only the set of allowable projects for the selected animal.
 *
 * @cfg includeDefaultProjects defaults to true
 */

//Created: 8-15-2024 R. Blasa

Ext4.define('onprc_ehr.form.field.SurgeryExceptionField', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_surgeryexceptionfield',


    expandToFitContent: true,
    caseSensitive: false,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
             defaultValue: '0 - None',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'sla',
                queryName: 'Reference_Data',
                columns: 'value',
                sort: 'sort_order',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'Surgicalobservationexception', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.SurgeryScoreField', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_surgeryscorefield',


    expandToFitContent: true,
    caseSensitive: false,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            defaultValue:'Normal',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'sla',
                queryName: 'Reference_Data',
                columns: 'value',
                sort: 'sort_order',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'Surgicalobservationscore', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.SurgeryOtherField', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_surgeryotherfield',


    expandToFitContent: true,
    caseSensitive: false,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'sla',
                queryName: 'Reference_Data',
                columns: 'value',
                defaultValue:'0 - None',
                sort: 'sort_order',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'Surgicalobservationother', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});
