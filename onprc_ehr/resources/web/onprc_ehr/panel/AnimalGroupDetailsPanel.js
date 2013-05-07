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

        items.push({
            header: 'Processing',
            items: [{
                name: 'View Summary of Serology Testing For This Group',
                url: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'processingSerology', 'query.Id/activeAnimalGroups/groups~contains': this.groupRow.getDisplayValue('name'), 'query.Id/demographics/calculated_status~eq': 'Alive'})
            },{
                name: 'View TB Testing Data For This Group',
                url: LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'demographicsMostRecentTBDate', 'query.Id/activeAnimalGroups/groups~contains': this.groupRow.getDisplayValue('name'), 'query.Id/demographics/calculated_status~eq': 'Alive'})
            }]
        });

        return items;
    }
});