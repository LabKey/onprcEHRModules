/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created: R.Blasa on 11/4/2016.
 */
Ext4.define('onprc_ehr.form.field.onprc_TB_TST_ObservationScores', {
    extend: 'Ext.form.field.ComboBox',
    alias: 'widget.onprc_TB_TST_ObservationScores',


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
                    LABKEY.Filter.create('ColumnName', 'TBTestObserveScore', LABKEY.Filter.Types.EQUAL)],
                autoLoad: true
            })
        });

        this.callParent(arguments);



    }
});