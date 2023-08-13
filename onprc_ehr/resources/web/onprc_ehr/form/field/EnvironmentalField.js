/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

//Created  2-21-2023  Blasa


Ext4.define('onprc_ehr.form.field.environ_servicetype', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-env_servicetype',


    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    forceSelection: true,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Environmental_Reference_Data',
                columns: 'value,columnName',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'ServiceType', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.environ_testLocation', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-env_testLocation',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    forceSelection: true,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Environmental_Reference_Data',
                columns: 'value,columnName',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'testLocation', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.environ_PassFail', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-env_passfail',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    forceSelection: true,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Environmental_Reference_Data',
                columns: 'value,columnName',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'Pass_Fail', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});
Ext4.define('onprc_ehr.form.field.environ_ChargeUnit', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-env_chargeunit',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    forceSelection: true,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Environmental_Reference_Data',
                columns: 'value,columnName',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'charge_unit', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.environ_Test_Results', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-env_testresults',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    forceSelection: true,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Environmental_Reference_Data',
                columns: 'value,columnName',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'test_results', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.environ_Test_Type', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-env_testtype',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    forceSelection: true,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Environmental_Reference_Data',
                columns: 'value,columnName',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'test_type', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});

Ext4.define('onprc_ehr.form.field.environ_Water_source', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc-env_watersource',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    forceSelection: true,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'value',
            valueField: 'value',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Environmental_Reference_Data',
                columns: 'value,columnName',
                sort: 'value',
                filterArray: [
                    LABKEY.Filter.create('enddate', null, LABKEY.Filter.Types.ISBLANK),
                    LABKEY.Filter.create('ColumnName', 'water_source', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});