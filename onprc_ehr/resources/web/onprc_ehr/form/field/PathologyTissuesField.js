/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created: R.Blasa 2-17-2021
 * */
Ext4.define('onprc_ehr.form.field.Path_Delivery', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_delivery',

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
                    LABKEY.Filter.create('ColumnName', 'NecropsyDelivery', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});


Ext4.define('onprc_ehr.form.field.Path_Approval', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_approval',


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
                    LABKEY.Filter.create('ColumnName', 'NecropsyDist', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});

Ext4.define('onprc_ehr.form.field.Path_Fasting', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_Fasting',

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
                    LABKEY.Filter.create('ColumnName', 'NecropsyFasting', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});

Ext4.define('onprc_ehr.form.field.Path_Location', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_location',

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
                    LABKEY.Filter.create('ColumnName', 'TissueLocation', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});

Ext4.define('onprc_ehr.form.field.Path_Preparation', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_preparation',


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
                    LABKEY.Filter.create('ColumnName', 'TissuePerf', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});

Ext4.define('onprc_ehr.form.field.Path_Priority', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_priority',


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
                    LABKEY.Filter.create('ColumnName', 'TissuePriority', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});

Ext4.define('onprc_ehr.form.field.Path_TissueLocation', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_tissueloc',

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
                    LABKEY.Filter.create('ColumnName', 'TissueLocation', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});

Ext4.define('onprc_ehr.form.field.Path_BillingGrade', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.path_billinggrade',

    nullCaption: '[Blank]',
    expandToFitContent: true,
    caseSensitive: false,
    anyMatch: true,
    typeAhead: true,

    initComponent: function(){
        Ext4.apply(this, {
            displayField:'displayName',
            valueField: 'idkey',
            queryMode: 'local',
            store: Ext4.create('LABKEY.ext4.data.Store', {
                schemaName: 'onprc_ehr',
                queryName: 'Reference_Data_IDkey',
                columns: 'idkey,columnName, displayName',
                sort: 'name',
                filterArray: [
                    LABKEY.Filter.create('columnName', 'Pathology_billing', LABKEY.Filter.EQUAL),
                    LABKEY.Filter.create('endDate', null, LABKEY.Filter.Types.ISBLANK)],

                autoLoad: true
            })
        });

        this.callParent(arguments);

    }
});