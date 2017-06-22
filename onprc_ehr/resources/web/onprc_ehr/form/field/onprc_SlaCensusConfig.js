/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * @cfg pairedWithRoomField.  Note: if true, you must implement getRoomField(), which returns the cognate ehr-roomfield
 */
Ext4.define('onprc_ehr.form.field.onprc_CageSize', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_CageSize',


    nullCaption: '[Blank]',
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
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                   LABKEY.Filter.create('ColumnName', 'cagesize', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});


Ext4.define('onprc_ehr.form.field.onprc_CageType', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_CageType',


    nullCaption: '[Blank]',
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
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'cagetype', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.onprc_Species', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_Species',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    typeAhead: true,
    caseSensitive: false,
    anyMatch: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'sla',
                queryName: 'Reference_Data',
                columns: 'value',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'specie', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 *
 * @cfg pairedWithRoomField.  Note: if true, you must implement getRoomField(), which returns the cognate ehr-roomfield
 */
Ext4.define('onprc_ehr.form.field.onprc_Roomfield', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_Roomfield',

    initComponent: function(){
        Ext4.apply(this, {
            queryMode: 'local',
            nullCaption: '[Blank]',
            expandToFitContent: true,
            typeAhead: true,
            matchFieldWidth: false,
            anyMatch: true,
            displayField: 'room',
            forceSelection: true,
            valueField: 'room',
            store: {
                type: 'labkey-store',
                schemaName: 'ehr_lookups',
                queryName: 'rooms',
                columns: 'room',
                sort: 'room',
                filterArray: [
                    LABKEY.Filter.create('dateDisabled', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('housingType', 589, LABKEY.Filter.Types.EQUAL)],     //Rodent Location
                autoLoad: true

            }
        });

        this.callParent(arguments);



    }
});

