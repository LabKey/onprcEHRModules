/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.AssignmentFilterType', {
    extend: 'LDK.panel.AbstractFilterType',
    alias: 'widget.onprc_ehr-assignmentfiltertype',

    initComponent: function(){
        this.items = this.getItems();

        this.callParent();
    },

    statics: {
        filterName: 'assignment',
        label: 'Assignment/Utilization'
    },

    getItems: function(){
        var toAdd = [];
        var ctx = this.filterContext;

        toAdd.push({
            width: 200,
            html: 'Assignment/Utilization:'
        });

        toAdd.push({
            xtype: 'panel',
            defaults: {
                border: false,
                width: 200,
                labelWidth: 90,
                labelAlign: 'top'
            },
            keys: [{
                key: Ext4.EventObject.ENTER,
                handler: this.tabbedReportPanel.onSubmit,
                scope: this.tabbedReportPanel
            }],
            items: [{
                xtype: 'labkey-combo',
                multiSelect: true,
                itemId: 'divisionField',
                fieldLabel: 'Division(s)',
                valueField: 'division',
                displayField: 'division',
                store: {
                    type: 'labkey-store',
                    schemaName: 'onprc_ehr',
                    sql: 'SELECT distinct division FROM onprc_ehr.investigators WHERE division is not null',
                    sort: 'division',
                    autoLoad: true
                },
                value: ctx.division ? ctx.division.split(',') :  null
            },{
                xtype: 'labkey-combo',
                multiSelect: true,
                itemId: 'investigatorField',
                fieldLabel: 'Investigator(s)',
                valueField: 'lastname',
                displayField: 'lastname',
                store: {
                    type: 'labkey-store',
                    schemaName: 'onprc_ehr',
                    sql: 'SELECT distinct lastname FROM onprc_ehr.investigators WHERE lastname is not null',
                    sort: 'lastname',
                    autoLoad: true
                },
                value: ctx.investigator ? ctx.investigator.split(',') :  null
            }]
        });

        return toAdd;
    },

    getFilters: function(){
        var obj = {
            division: this.down('#divisionField').getValue(),
            investigator: this.down('#investigatorField').getValue()
        };

        for (var key in obj){
            if (Ext4.isArray(obj[key]))
                obj[key] = obj[key].join(',')
        }

        return obj;
    },

    getFilterArray: function(tab, subject){
        var filterArray = {
            removable: [],
            nonRemovable: []
        };

        var division = this.down('#divisionField').getValue();
        if(Ext4.isArray(division)){
            division = division.join(';');
        }

        var investigator = this.down('#investigatorField').getValue();
        if(Ext4.isArray(investigator)){
            investigator = investigator.join(';');
        }

        if (division){
            filterArray.nonRemovable.push(LABKEY.Filter.create('Id/activeAssignments/divisions', division, LABKEY.Filter.Types.CONTAINS_ONE_OF));
        }

        if (investigator){
            filterArray.nonRemovable.push(LABKEY.Filter.create('Id/activeAssignments/investigators', investigator, LABKEY.Filter.Types.CONTAINS_ONE_OF));
        }

        return filterArray;
    },

    validateReport: function(report){
        return null;
    },

    checkValid: function(){
        if (!this.down('#divisionField').getValue() && !this.down('#investigatorField').getValue()){
            alert('Error: Must Choose A Division or an Investigator');
            return false;
        }

        return true;
    },

    getTitle: function(){
        var title = [];

        var divisionText = this.down('#divisionField').getValue();
        if (Ext4.isArray(divisionText)){
            if (divisionText.length < 8)
                divisionText = 'Division: ' + divisionText.join(', ');
            else
                divisionText = 'Multiple divisions selected';
        }

        if (divisionText)
            title.push(divisionText);

        var investigatorText = this.down('#investigatorField').getValue();
        if (Ext4.isArray(investigatorText)){
            if (investigatorText.length < 8)
                investigatorText = 'Investigator: ' + investigatorText.join(', ');
            else
                investigatorText = 'Multiple investigators selected';
        }

        if (investigatorText)
            title.push(investigatorText);

        return title.join(', ');
    }
});