/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
//Modified: 9-8-2022  R.Blasa
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
                itemId: 'investigatorField',
                fieldLabel: 'Investigator(s)',
                valueField: 'lastname',
                displayField: 'lastname',
                store: {
                    type: 'labkey-store',
                    schemaName: 'ehr',
                    sql: 'SELECT distinct investigatorId.lastname FROM ehr.protocol WHERE activeAnimals.TotalActiveAnimals > 0',
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


        var investigator = this.down('#investigatorField').getValue();
        if(Ext4.isArray(investigator)){
            investigator = investigator.join(';');
        }


        if (investigator){
            filterArray.nonRemovable.push(LABKEY.Filter.create('Id/activeAssignments/investigators', investigator, LABKEY.Filter.Types.CONTAINS_ONE_OF));
        }

        return filterArray;
    },

    validateReportForFilterType: function(report){
        return null;
    },

    isValid: function(){
           return true;
    },

    getFilterInvalidMessage: function(){
        return 'Error: Must Choose A Division or an Investigator';
    },

    getTitle: function(){
        var title = [];

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