/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.AnimalGroupDetailsPanel', {
    extend: 'EHR.panel.AnimalGroupDetailsPanel',

    onLoad: function(results){
        this.removeAll();

        if (!results || !results.rows || !results.rows.length){
            Ext4.Msg.alert('Error', 'Unable to find group with Id: ' + this.groupId);
            return;
        }

        var toAdd = [];

        LDK.Assert.assertNotEmpty('Group name was empty', results.rows[0]);
        this.groupRow = new LDK.SelectRowsRow(results.rows[0]);

        toAdd.push({
            xtype: 'ldk-webpartpanel',
            title: 'Group Details',
            items: [{
                border: false,
                defaults: {
                    border: false,
                    xtype: 'displayfield'
                },
                items: [{
                    fieldLabel: 'Name',
                    value: this.groupRow.getDisplayValue('name')
                },{
                    fieldLabel: 'Date Created',
                    value: this.groupRow.getFormattedDateValue('date', LABKEY.extDefaultDateFormat)
                },{
                    fieldLabel: 'Date Disabled',
                    value: this.groupRow.getFormattedDateValue('enddate', LABKEY.extDefaultDateFormat)
                },{
                    fieldLabel: 'Purpose',
                    value: this.groupRow.getDisplayValue('purpose')
                },{
                    fieldLabel: 'Comments',
                    value: this.groupRow.getDisplayValue('comment')
                }]
            }]
        });

        toAdd.push({
            html: '',
            style: 'padding-bottom: 20px;'
        });

        toAdd.push({
            xtype: 'ldk-webpartpanel',
            title: 'Misc Reports',
            items: [{
                xtype: 'ldk-navpanel',
                border: false,
                sections: this.getReportItems()
            }]
        });

        toAdd.push({
            html: '',
            style: 'padding-bottom: 20px;'
        });

        var fieldKey = 'Id/animalGroupsPivoted/' + this.groupRow.getDisplayValue('name') + '::valueField';
        toAdd.push({
            xtype: 'ldk-webpartpanel',
            title: 'Group Overview',
            items: [{
                xtype: 'onprc_ehr-populationpanel',
                filterArray: [
                    LABKEY.Filter.create('calculated_status', 'Alive', LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create(fieldKey, 'yes', LABKEY.Filter.Types.EQUAL)
                ],
                rowField: EHR.panel.PopulationPanel.FIELDS.species,
                colFields: [EHR.panel.PopulationPanel.FIELDS.ageclass, EHR.panel.PopulationPanel.FIELDS.gender],
                itemId: 'population'
            },{
                xtype: 'ehr-clinicalsummarypanel',
                style: 'padding-top: 20px',
                filterArray: [
                    LABKEY.Filter.create('Id/dataset/demographics/calculated_status', 'Alive', LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create(fieldKey, 'yes', LABKEY.Filter.Types.EQUAL)
                ]
            }]
        });

        toAdd.push({
            html: '',
            style: 'padding-bottom: 20px;'
        });

        toAdd.push({
            xtype: 'ldk-querypanel',
            queryConfig: {
                schemaName: 'study',
                queryName: 'animalGroupHousingSummary',
                frame: 'portal',
                title: 'Current Housing',
                filterArray: [LABKEY.Filter.create('groupId', this.groupId)]
            }
        });

        toAdd.push({
            html: '',
            style: 'padding-bottom: 20px;'
        });

        toAdd.push({
            xtype: 'ldk-querypanel',
            queryConfig: {
                schemaName: 'study',
                queryName: 'animal_group_members',
                frame: 'portal',
                title: 'Group Members',
                viewName: 'Active Members',
                filterArray: [LABKEY.Filter.create('groupId', this.groupId)]
            }
        });

        this.add(toAdd);
    },

    getReportItems: function(){
        var items = this.callParent(arguments);

        items[0].items.push({
            name: 'View Summary of Birth Rates For This Group',
            url: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'animalGroupBirthRateSummary', 'query.groupId/name~eq': this.groupRow.getDisplayValue('name')})
        });

        items[0].items.push({
            name: 'View Summary of Morbidity and Mortality For This Group Over A Date Range',
            url: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'animalGroupProblemSummary', 'query.groupId/name~eq': this.groupRow.getDisplayValue('name')})
        });

        items[0].items.push({
            name: 'View Summary of Kinship Within Members of This Group',
            url: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'animalGroupAverageKinship', 'query.groupId/name~eq': this.groupRow.getDisplayValue('name')})
        });

        items[0].items.push({
            name: 'Processing Information',
            url: LABKEY.ActionURL.buildURL('onprc_ehr', 'groupProcessing', null, {groupName: this.groupRow.getDisplayValue('name')})
        });

        return items;
    }
});