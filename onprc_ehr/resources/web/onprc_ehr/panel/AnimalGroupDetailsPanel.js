/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('ONPRC_EHR.panel.AnimalGroupDetailsPanel', {
    extend: 'EHR.panel.AnimalGroupDetailsPanel',

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